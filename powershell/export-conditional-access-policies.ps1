<#
.SYNOPSIS
Exports Conditional Access policies (sanitised) to JSON and creates a readable summary CSV.

.DESCRIPTION
Connects to Microsoft Graph, retrieves Conditional Access policies, removes tenant-specific identifiers
where possible, and exports:
- JSON file for reference
- CSV summary for quick review

REQUIREMENTS
- Microsoft.Graph PowerShell modules
- Permissions: Policy.Read.All

NOTES
Do not commit raw exports from production tenants. Keep outputs private.
#>

param(
    [string]$OutputPath = ".\output"
)

$ErrorActionPreference = "Stop"

function Ensure-Module {
    param([string]$Name)
    if (-not (Get-Module -ListAvailable -Name $Name)) {
        Install-Module $Name -Scope CurrentUser -Force
    }
    Import-Module $Name -ErrorAction Stop
}

function Sanitise-Policy {
    param($Policy)

    $p = $Policy | ConvertTo-Json -Depth 25 | ConvertFrom-Json

    $p.id = $null

    if ($p.conditions -and $p.conditions.users) {
        foreach ($field in "includeUsers","excludeUsers","includeGroups","excludeGroups","includeRoles","excludeRoles") {
            if ($p.conditions.users.$field) { $p.conditions.users.$field = @() }
        }
    }

    if ($p.conditions -and $p.conditions.locations) {
        foreach ($field in "includeLocations","excludeLocations") {
            if ($p.conditions.locations.$field) { $p.conditions.locations.$field = @() }
        }
    }

    return $p
}

Ensure-Module -Name "Microsoft.Graph.Authentication"
Ensure-Module -Name "Microsoft.Graph.Identity.SignIns"

Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "Policy.Read.All" | Out-Null

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$jsonOut = Join-Path $OutputPath "conditional-access-policies-sanitised-$timestamp.json"
$csvOut  = Join-Path $OutputPath "conditional-access-policies-summary-$timestamp.csv"

Write-Host "Retrieving Conditional Access policies..."
$policies = Get-MgIdentityConditionalAccessPolicy -All

if (-not $policies) {
    Write-Host "No Conditional Access policies found."
    return
}

$sanitised = $policies | ForEach-Object { Sanitise-Policy -Policy $_ }
$sanitised | ConvertTo-Json -Depth 30 | Out-File -FilePath $jsonOut -Encoding utf8

$summary = $policies | ForEach-Object {
    [pscustomobject]@{
        DisplayName  = $_.DisplayName
        State        = $_.State
        CreatedDate  = $_.CreatedDateTime
        ModifiedDate = $_.ModifiedDateTime
        GrantControls = ($_.GrantControls.BuiltInControls -join "; ")
    }
}

$summary | Export-Csv -Path $csvOut -NoTypeInformation -Encoding utf8

Write-Host "Done."
Write-Host "Sanitised JSON: $jsonOut"
Write-Host "Summary CSV:    $csvOut"

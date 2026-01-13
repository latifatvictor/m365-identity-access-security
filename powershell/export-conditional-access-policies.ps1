<#
.SYNOPSIS
Exports Conditional Access policies (sanitised) to JSON and creates a readable summary CSV.

.DESCRIPTION
Connects to Microsoft Graph, retrieves Conditional Access policies, removes tenant-specific identifiers
where possible, exports:
- JSON file for reference
- CSV summary for quick review

REQUIREMENTS
- Microsoft.Graph PowerShell module
- Permissions: Policy.Read.All

NOTES
Safe for GitHub: do not commit raw exports containing tenant identifiers. Use the sanitised outputs only.
#>

param(
    [string]$OutputPath = ".\output"
)

$ErrorActionPreference = "Stop"

function Ensure-Module {
    param([string]$Name)
    if (-not (Get-Module -ListAvailable -Name $Name)) {
        Write-Host "Installing module: $Name"
        Install-Module $Name -Scope CurrentUser -Force
    }
    Import-Module $Name -ErrorAction Stop
}

function Sanitise-Policy {
    param($Policy)

    # Create a shallow copy for sanitising
    $p = $Policy | ConvertTo-Json -Depth 20 | ConvertFrom-Json

    # Remove IDs where they commonly appear
    $p.id = $null
    if ($p.conditions -and $p.conditions.users) {
        # Users and groups may contain IDs, keep structure but remove raw IDs
        if ($p.conditions.users.includeUsers) { $p.conditions.users.includeUsers = @() }
        if ($p.conditions.users.excludeUsers) { $p.conditions.users.excludeUsers = @() }
        if ($p.conditions.users.includeGroups) { $p.conditions.users.includeGroups = @() }
        if ($p.conditions.users.excludeGroups) { $p.conditions.users.excludeGroups = @() }
        if ($p.conditions.users.includeRoles) { $p.conditions.users.includeRoles = @() }
        if ($p.conditions.users.excludeRoles) { $p.conditions.users.excludeRoles = @() }
    }

    # Named locations can contain IDs, keep intent but remove IDs
    if ($p.conditions -and $p.conditions.locations) {
        if ($p.conditions.locations.includeLocations) { $p.conditions.locations.includeLocations = @() }
        if ($p.conditions.locations.excludeLocations) { $p.conditions.locations.excludeLocations = @() }
    }

    return $p
}

# 1. Ensure modules
Ensure-Module -Name "Microsoft.Graph.Authentication"
Ensure-Module -Name "Microsoft.Graph.Identity.SignIns"

# 2. Connect
Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "Policy.Read.All" | Out-Null

# 3. Prepare output
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$jsonOut = Join-Path $OutputPath "conditional-access-policies-sanitised-$timestamp.json"
$csvOut  = Join-Path $OutputPath "conditional-access-policies-summary-$timestamp.csv"

# 4. Get policies
Write-Host "Retrieving Conditional Access policies..."
$policies = Get-MgIdentityConditionalAccessPolicy -All

if (-not $policies) {
    Write-Host "No Conditional Access policies found."
    return
}

# 5. Sanitise and export JSON
$sanitised = @()
foreach ($policy in $policies) {
    $sanitised += (Sanitise-Policy -Policy $policy)
}

$sanitised | ConvertTo-Json -Depth 30 | Out-File -FilePath $jsonOut -Encoding utf8

# 6. Build readable CSV summary
$summary = $policies | ForEach-Object {
    [pscustomobject]@{
        DisplayName   = $_.DisplayName
        State         = $_.State
        CreatedDate   = $_.CreatedDateTime
        ModifiedDate  = $_.ModifiedDateTime
        GrantControls = ($_.GrantControls.BuiltInControls -join "; ")
        Session       = ($_.SessionControls | ConvertTo-Json -Compress)
    }
}

$summary | Export-Csv -Path $csvOut -NoTypeInformation -Encoding utf8

Write-Host "Done."
Write-Host "Sanitised JSON: $jsonOut"
Write-Host "Summary CSV:    $csvOut"

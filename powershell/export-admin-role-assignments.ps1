<#
.SYNOPSIS
Exports Entra ID directory role assignments (admin roles) to a CSV for review.

.DESCRIPTION
Connects to Microsoft Graph and exports who has which admin roles.
Designed for least privilege reviews and governance.

REQUIREMENTS
- Microsoft.Graph PowerShell modules
- Permissions: RoleManagement.Read.Directory, Directory.Read.All

NOTES
Do not commit exports from production tenants (user details). Keep outputs private.
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

Ensure-Module -Name "Microsoft.Graph.Authentication"
Ensure-Module -Name "Microsoft.Graph.Identity.DirectoryManagement"
Ensure-Module -Name "Microsoft.Graph.Users"

Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "RoleManagement.Read.Directory","Directory.Read.All" | Out-Null

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$csvOut = Join-Path $OutputPath "entra-admin-role-assignments-$timestamp.csv"

Write-Host "Retrieving directory roles..."
$roles = Get-MgDirectoryRole -All

if (-not $roles) {
    Write-Host "No directory roles found. (Roles may not be activated in this tenant.)"
    return
}

$results = @()

foreach ($role in $roles) {
    Write-Host "Processing role: $($role.DisplayName)"
    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All

    foreach ($m in $members) {
        $odataType = $m.AdditionalProperties.'@odata.type'

        if ($odataType -eq "#microsoft.graph.user") {
            $user = Get-MgUser -UserId $m.Id -Property "displayName,userPrincipalName,accountEnabled" -ErrorAction SilentlyContinue
            $results += [pscustomobject]@{
                RoleName          = $role.DisplayName
                MemberType        = "User"
                DisplayName       = $user.DisplayName
                UserPrincipalName = $user.UserPrincipalName
                AccountEnabled    = $user.AccountEnabled
            }
        }
        elseif ($odataType -eq "#microsoft.graph.group") {
            $results += [pscustomobject]@{
                RoleName          = $role.DisplayName
                MemberType        = "Group"
                DisplayName       = $m.AdditionalProperties.displayName
                UserPrincipalName = ""
                AccountEnabled    = ""
            }
        }
        else {
            $results += [pscustomobject]@{
                RoleName          = $role.DisplayName
                MemberType        = "Other"
                DisplayName       = $m.AdditionalProperties.displayName
                UserPrincipalName = ""
                AccountEnabled    = ""
            }
        }
    }
}

$results | Sort-Object RoleName, MemberType, DisplayName | Export-Csv -Path $csvOut -NoTypeInformation -Encoding utf8

Write-Host "Done."
Write-Host "Report saved to: $csvOut"

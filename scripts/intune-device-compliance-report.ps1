<#
.SYNOPSIS
Generates an Intune device compliance report (CSV) with encryption and OS details.

.DESCRIPTION
Connects to Microsoft Graph, pulls managed devices from Intune, outputs a CSV
suitable for operational reporting:
- Device name
- Primary user (if available)
- OS and version
- Compliance state
- Encryption state (where available)
- Last sync time

REQUIREMENTS
- Microsoft.Graph PowerShell module
- Permissions: DeviceManagementManagedDevices.Read.All

NOTES
Safe for GitHub: do not commit exports with real user/device names from production tenants.
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

# Modules
Ensure-Module -Name "Microsoft.Graph.Authentication"
Ensure-Module -Name "Microsoft.Graph.DeviceManagement"

# Connect
Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All" | Out-Null

# Output folder
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$csvOut = Join-Path $OutputPath "intune-device-compliance-report-$timestamp.csv"

# Get devices
Write-Host "Retrieving Intune managed devices..."
$devices = Get-MgDeviceManagementManagedDevice -All

if (-not $devices) {
    Write-Host "No managed devices found."
    return
}

# Build report
$report = $devices | ForEach-Object {
    [pscustomobject]@{
        DeviceName       = $_.DeviceName
        OperatingSystem  = $_.OperatingSystem
        OSVersion        = $_.OsVersion
        ComplianceState  = $_.ComplianceState
        EncryptionState  = $_.EncryptionState
        LastSyncDateTime = $_.LastSyncDateTime
        UserPrincipal    = $_.UserPrincipalName
        ManagementAgent  = $_.ManagementAgent
    }
}

$report | Sort-Object ComplianceState, OperatingSystem, DeviceName | Export-Csv -Path $csvOut -NoTypeInformation -Encoding utf8

Write-Host "Done."
Write-Host "Report saved to: $csvOut"

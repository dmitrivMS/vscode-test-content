#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SourcePath,

    [Parameter()]
    [string]$DestinationPath = ".\backup",

    [Parameter()]
    [int]$RetentionDays = 30
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $SourcePath)) {
    Write-Error "Source path '$SourcePath' does not exist."
    return
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$archiveName = "backup_$timestamp.zip"
$archivePath = Join-Path $DestinationPath $archiveName

New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
Compress-Archive -Path "$SourcePath\*" -DestinationPath $archivePath -CompressionLevel Optimal

# Remove old backups
Get-ChildItem -Path $DestinationPath -Filter '*.zip' |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$RetentionDays) } |
    Remove-Item -Force

Write-Host "Backup created: $archivePath" -ForegroundColor Green

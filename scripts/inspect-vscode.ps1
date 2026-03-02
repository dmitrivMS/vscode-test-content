<#
.SYNOPSIS
    Inspects VS Code binaries for signatures, metadata, and architecture.

.DESCRIPTION
    Scans a VS Code installation directory for binary files (exe, dll, node, ps1, etc.)
    and reports each file's relative path, size, Authenticode signature status,
    product name, version, and binary architecture.

.PARAMETER Directory
    The path to the VS Code installation directory to scan.
    If not specified, the directory is resolved from the InstallType parameter.

.PARAMETER InstallType
    The type of installation to inspect: user or system.
    Ignored when Directory is specified.

.PARAMETER Quality
    The VS Code quality: stable, insider, or exploration. Used to resolve the
    installation directory when InstallType is specified.

.EXAMPLE
    .\inspect-vscode.ps1 -Directory "C:\Program Files\Microsoft VS Code"
    .\inspect-vscode.ps1 -InstallType user
    .\inspect-vscode.ps1 -InstallType system -Quality stable
#>

param(
    [string]$Directory,

    [ValidateSet('user', 'system')]
    [string]$InstallType,

    [ValidateSet('stable', 'insider', 'exploration')]
    [string]$Quality = 'insider'
)

$ErrorActionPreference = 'Stop'

# Resolve the target directory
if ($Directory) {
    $targetDir = $Directory
} elseif ($InstallType) {
    $qualitySuffix = switch ($Quality) {
        'stable'      { '' }
        'insider'     { ' Insiders' }
        'exploration' { ' Exploration' }
    }
    $appName = "Microsoft VS Code$qualitySuffix"
    if ($InstallType -eq 'user') {
        $targetDir = Join-Path $env:LOCALAPPDATA "Programs\$appName"
    } else {
        $targetDir = Join-Path $env:ProgramFiles $appName
    }
} else {
    Write-Error "Specify either -Directory or -InstallType."
    exit 1
}

if (-not (Test-Path $targetDir)) {
    Write-Error "Directory not found: $targetDir"
    exit 1
}

$targetDir = (Resolve-Path $targetDir).Path
Write-Host "Scanning: $targetDir"
Write-Host ""

# File extensions to inspect
$extensions = @('.exe', '.dll', '.sys', '.cab', '.cat', '.msi', '.jar', '.ocx',
                '.ps1', '.psm1', '.psd1', '.ps1xml', '.pssc1', '.node')

# PE architecture detection via PE header
function Get-BinaryArchitecture {
    param([string]$FilePath)

    try {
        $stream = [System.IO.File]::OpenRead($FilePath)
        $reader = New-Object System.IO.BinaryReader($stream)

        # Read DOS header magic (MZ)
        $dosSignature = $reader.ReadUInt16()
        if ($dosSignature -ne 0x5A4D) {
            $reader.Close()
            $stream.Close()
            return 'N/A'
        }

        # Seek to e_lfanew (offset 0x3C) to find PE header offset
        $stream.Position = 0x3C
        $peOffset = $reader.ReadInt32()

        # Read PE signature
        $stream.Position = $peOffset
        $peSignature = $reader.ReadUInt32()
        if ($peSignature -ne 0x00004550) {
            $reader.Close()
            $stream.Close()
            return 'N/A'
        }

        # Read Machine field from IMAGE_FILE_HEADER
        $machine = $reader.ReadUInt16()

        $reader.Close()
        $stream.Close()

        switch ($machine) {
            0x014C { return 'x86' }
            0x8664 { return 'x64' }
            0xAA64 { return 'ARM64' }
            0x01C4 { return 'ARMv7' }
            default { return "Unknown (0x{0:X4})" -f $machine }
        }
    } catch {
        return 'N/A'
    }
}

$files = Get-ChildItem -Path $targetDir -Recurse -File |
    Where-Object { $extensions -contains $_.Extension.ToLower() -or $_.Name -eq 'node' -or $_.Name -eq 'node.exe' }

if ($files.Count -eq 0) {
    Write-Host "No binary files found."
    exit 0
}

$results = foreach ($file in $files) {
    $relativePath = $file.FullName.Substring($targetDir.Length).TrimStart('\')
    $sizeKB = [math]::Round($file.Length / 1KB, 1)

    # Authenticode signature
    $sig = Get-AuthenticodeSignature -FilePath $file.FullName
    $sigStatus = $sig.Status.ToString()

    # File version info (Product Name, Version)
    $versionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($file.FullName)
    $productName = if ($versionInfo.ProductName) { $versionInfo.ProductName } else { '-' }
    $productVersion = if ($versionInfo.ProductVersion) { $versionInfo.ProductVersion } else { '-' }

    # Architecture
    $arch = Get-BinaryArchitecture -FilePath $file.FullName

    [PSCustomObject]@{
        RelativePath   = $relativePath
        'Size (KB)'    = $sizeKB
        Signature      = $sigStatus
        ProductName    = $productName
        ProductVersion = $productVersion
        Architecture   = $arch
    }
}

$results | Format-Table -Property RelativePath, 'Size (KB)', Signature, Architecture, ProductName, ProductVersion -AutoSize -Wrap

# Summary
$total = $results.Count
$signed = ($results | Where-Object { $_.Signature -eq 'Valid' }).Count
$unsigned = $total - $signed
$noProduct = ($results | Where-Object { $_.ProductName -eq '-' }).Count

Write-Host ""
Write-Host "Summary"
Write-Host "-------"
Write-Host "Total files:          $total"
Write-Host "Valid signatures:     $signed"
Write-Host "Missing/invalid sig:  $unsigned"
Write-Host "Missing product name: $noProduct"

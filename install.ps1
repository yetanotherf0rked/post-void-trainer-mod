# ===============================================
# Post Void Trainer Mod (1.0.3b)
# ===============================================
# Configuration
$config = @{
    GlobalVersionCheck = "1.0.3b"
    DatawinFile        = "data.win"
    DatawinBakFile     = "data.win.bak"
    ExpectedChecksum   = "3433ABB6681C6685157F8E896C568836950FD25C679CF7AD96AE99AF39E002EF"
    UndertaleModCliUrl = "https://github.com/UnderminersTeam/UndertaleModTool/releases/download/bleeding-edge/CLI-windows-latest-Debug-isBundled-true.zip"
    DefaultGamePath    = "C:\Program Files (x86)\Steam\steamapps\common\POST VOID"
    PatchFileName      = "trainer_mod.patch"
    PathPatch          = (Split-Path -Parent $MyInvocation.MyCommand.Definition)
    UMTCliPath         = (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "UMT_CLI")
}

# ----------------------------
# Helper: Format path as relative if inside $config.PathPatch.
# ----------------------------
function Format-Path {
    param(
        [string]$Path,
        [string]$Base = $config.PathPatch
    )
    if ($Path -like "$Base*") {
        return ".\" + $Path.Substring($Base.Length).TrimStart("\")
    }
    return $Path
}

# ----------------------------
# Helper: Write a message from parts.
# Each part is a hashtable with a "text" key.
# ----------------------------
function Write-MessageParts {
    param(
        [ValidateSet("OK", "Loading", "Error")]
        [string]$Type,
        [Parameter(Mandatory=$true)]
        [array]$Parts
    )
    switch ($Type) {
        "OK"      { Write-Host -NoNewline "[OK] " -ForegroundColor Green }
        "Loading" { Write-Host -NoNewline "[...] " -ForegroundColor Cyan }
        "Error"   { Write-Host -NoNewline "[ERR] " -ForegroundColor Red }
    }
    foreach ($part in $Parts) {
         Write-Host -NoNewline $part.text
    }
    Write-Host ""
}

# ----------------------------
# Banner
# ----------------------------
$banner = @"
==============================
 Post Void Trainer Mod ($($config.GlobalVersionCheck))
==============================
"@
Write-Host $banner -ForegroundColor Yellow

# ----------------------------
# Ensure Backup of data.win with Correct Checksum
# ----------------------------
function Backup-Datawin {
    param([string]$gamePath)
    $dataWin    = Join-Path $gamePath $config.DatawinFile
    $dataWinBak = Join-Path $gamePath $config.DatawinBakFile

    # Function to calculate checksum
    function Get-Checksum($file) {
        try {
            return (Get-FileHash -Path $file -Algorithm SHA256).Hash
        }
        catch {
            return ""
        }
    }

    # If backup doesn't exist, verify data.win and create backup.
    if (-not (Test-Path $dataWinBak)) {
        if (Test-Path $dataWin) {
            $hash = Get-Checksum $dataWin
            if ($hash -ieq $config.ExpectedChecksum) {
                Write-MessageParts "Loading" @(
                    @{ text = "Checksum verified for data.win. Creating backup to " },
                    @{ text = $config.DatawinBakFile },
                    @{ text = " ..." }
                )
                Copy-Item $dataWin $dataWinBak -Force
            }
            else {
                Write-MessageParts "Error" @(
                    @{ text = "data.win checksum invalid. Exiting." }
                )
                exit 1
            }
        }
        else {
            Write-MessageParts "Error" @(
                @{ text = "data.win not found in game directory. Exiting." }
            )
            exit 1
        }
    }
    else {
        # Backup exists; verify its checksum.
        $hashBak = Get-Checksum $dataWinBak
        if (-not ($hashBak -ieq $config.ExpectedChecksum)) {
            Write-MessageParts "Loading" @(
                @{ text = "Backup checksum invalid. Recreating backup..." }
            )
            Remove-Item $dataWinBak -Force
            if (Test-Path $dataWin) {
                $hash = Get-Checksum $dataWin
                if ($hash -ieq $config.ExpectedChecksum) {
                    Write-MessageParts "Loading" @(
                        @{ text = "Checksum verified for data.win. Creating backup to " },
                        @{ text = $config.DatawinBakFile }
                    )
                    Copy-Item $dataWin $dataWinBak -Force
                }
                else {
                    Write-MessageParts "Error" @(
                        @{ text = "data.win checksum invalid. Exiting." }
                    )
                    exit 1
                }
            }
            else {
                Write-MessageParts "Error" @(
                    @{ text = "data.win not found. Exiting." }
                )
                exit 1
            }
        }
        else {
            Write-MessageParts "OK" @(
                @{ text = "Backup file checksum verified. Proceeding with patching." }
            )
        }
    }
    return @{ DataWin = $dataWin; DataWinBak = $dataWinBak }
}

# ----------------------------
# Get POST VOID Game Installation Path
# ----------------------------
function Get-GamePath {
    if (Test-Path $config.DefaultGamePath) {
        Write-MessageParts "OK" @(
            @{ text = "Found POST VOID in default directory: " },
            @{ text = (Format-Path $config.DefaultGamePath) }
        )
        return $config.DefaultGamePath
    }
    $userPath = Read-Host "Enter the full path to your POST VOID game installation"
    if (Test-Path $userPath) {
        return $userPath
    }
    Write-MessageParts "Error" @(
        @{ text = "Game path not found. Exiting." }
    )
    exit 1
}

# ----------------------------
# Parse Patch File to Get Files to Patch (only print count)
# ----------------------------
function Get-FilesToPatch {
    param([string]$patchFilePath)
    if (-not (Test-Path $patchFilePath)) {
        Write-MessageParts "Error" @(
            @{ text = "Patch file " },
            @{ text = $config.PatchFileName },
            @{ text = " not found in " },
            @{ text = (Format-Path $config.PathPatch) },
            @{ text = ". Exiting." }
        )
        exit 1
    }
    $files = Get-Content $patchFilePath | ForEach-Object {
        if ($_ -match '^diff --git a\/(.+?) b\/(.+)$') { $matches[2] }
    } | Sort-Object -Unique
    if ($files.Count -eq 0) {
        Write-MessageParts "Error" @(
            @{ text = "No files detected in patch file. Exiting." }
        )
        exit 1
    }
    Write-MessageParts "Loading" @(
        @{ text = "Files to patch: (" },
        @{ text = $files.Count.ToString() },
        @{ text = " files)" }
    )
    return $files
}

# ----------------------------
# Download or Locate UndertaleModCli.exe
# ----------------------------
function Get-UMTCLI {
    $cliPath = Join-Path $config.UMTCliPath "UndertaleModCli.exe"
    if (Test-Path $cliPath) {
         Write-MessageParts "OK" @(
             @{ text = "Found UndertaleModCli.exe at " },
             @{ text = (Format-Path $cliPath) }
         )
         return $cliPath
    }
    $inputPath = Read-Host "Enter the full path to UndertaleModCli.exe (leave blank to download it)"
    if ($inputPath) {
         if (Test-Path $inputPath) {
            Write-MessageParts "OK" @(
                @{ text = "Using specified UndertaleModCli.exe at " },
                @{ text = (Format-Path $inputPath) }
            )
            return $inputPath
         } else {
            Write-MessageParts "Error" @(
                @{ text = "Specified UndertaleModCli.exe not found. Exiting." }
            )
            exit 1
         }
    }
    Write-MessageParts "Loading" @(
         @{ text = "Downloading UndertaleModCli from " },
         @{ text = $config.UndertaleModCliUrl },
         @{ text = " ..." }
    )
    $tempZip = Join-Path $env:TEMP "UMT_CLI.zip"
    try {
         Invoke-WebRequest -Uri $config.UndertaleModCliUrl -OutFile $tempZip -UseBasicParsing
         Write-MessageParts "OK" @(
             @{ text = "Download complete." }
         )
    }
    catch {
         Write-MessageParts "Error" @(
             @{ text = "Error downloading UndertaleModCli. Exiting." }
         )
         exit 1
    }
    if (!(Test-Path $config.UMTCliPath)) {
         New-Item -ItemType Directory -Path $config.UMTCliPath | Out-Null
    }
    try {
         Expand-Archive -Path $tempZip -DestinationPath $config.UMTCliPath -Force
         Write-MessageParts "OK" @(
             @{ text = "Extraction complete." }
         )
    }
    catch {
         Write-MessageParts "Error" @(
             @{ text = "Error extracting the archive. Exiting." }
         )
         exit 1
    }
    $executable = Get-ChildItem -Path $config.UMTCliPath -Filter "UndertaleModCli.exe" -Recurse | Select-Object -First 1
    if ($executable) {
         Write-MessageParts "OK" @(
             @{ text = "Found UndertaleModCli.exe at: " },
             @{ text = (Format-Path $executable.FullName) }
         )
         return $executable.FullName
    } else {
         Write-MessageParts "Error" @(
             @{ text = "Could not locate UndertaleModCli.exe in the extracted files. Exiting." }
         )
         exit 1
    }
}

# ----------------------------
# Dump Code Files from data.win Backup
# ----------------------------
function Dump-CodeFiles {
    param(
        [string]$dataWinBak,
        [array]$dumpFiles,
        [string]$pathUMTCLI
    )
    $codeDumpDir = Join-Path $config.PathPatch "dumped_code"
    if (Test-Path $codeDumpDir) { Remove-Item $codeDumpDir -Recurse -Force }
    New-Item -ItemType Directory -Path $codeDumpDir | Out-Null
    Write-MessageParts "Loading" @(
        @{ text = "Dumping specified code files from " },
        @{ text = $dataWinBak },
        @{ text = " ..." }
    )
    $dumpArgs = @("dump", "$dataWinBak", "--code") + $dumpFiles + @("-o", "$codeDumpDir")
    & "$pathUMTCLI" @dumpArgs | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-MessageParts "Error" @(
            @{ text = "Error dumping code files. Exiting." }
        )
        exit 1
    }
    Write-MessageParts "OK" @(
        @{ text = "Code files dumped to: " },
        @{ text = (Format-Path $codeDumpDir) }
    )
    return $codeDumpDir
}

# ----------------------------
# Initialize Git Repository & Commit Files
# ----------------------------
function Initialize-GitRepo {
    param([string]$dumpBaseDir)
    Write-MessageParts "Loading" @(
        @{ text = "Initializing git repository in dumped code directory ..." }
    )
    Push-Location $dumpBaseDir
    git init | Out-Null
    git config core.longpaths true | Out-Null
    git config core.autocrlf false | Out-Null
    git add .
    $commitResult = git commit -m "Initial files" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-MessageParts "Error" @(
            @{ text = "Warning: Git commit encountered issues (possibly due to long filenames)." }
        )
    }
    Pop-Location
    Write-MessageParts "OK" @(
        @{ text = "Git repository initialized and initial files committed." }
    )
}

# ----------------------------
# Apply Trainer Mod Patch
# ----------------------------
function Apply-Patch {
    param(
        [string]$dumpBaseDir,
        [string]$patchFile
    )
    Write-MessageParts "Loading" @(
        @{ text = "Applying patch from " },
        @{ text = (Format-Path $patchFile) },
        @{ text = " ..." }
    )
    Push-Location $dumpBaseDir
    git apply $patchFile
    if ($LASTEXITCODE -ne 0) {
        Write-MessageParts "Error" @(
            @{ text = "Error applying patch. Exiting." }
        )
        Pop-Location
        exit 1
    }
    Pop-Location
    Write-MessageParts "OK" @(
        @{ text = "Patch applied successfully." }
    )
}

# ----------------------------
# Replace Code Files in data.win
# ----------------------------
function Replace-CodeFiles {
    param(
        [string]$dumpBaseDir,
        [string]$dataWinBak,
        [array]$filesToPatch,
        [string]$pathUMTCLI,
        [string]$dataWin
    )
    Write-MessageParts "Loading" @(
        @{ text = "Replacing patched code files in data.win ..." }
    )
    Push-Location $dumpBaseDir
    $replaceFiles = foreach ($file in $filesToPatch) {
        $baseName   = [System.IO.Path]::GetFileNameWithoutExtension($file)
        $dumpedFile = Join-Path $dumpBaseDir $file
        "$baseName=$dumpedFile"
    }
    $replaceArgs = @("replace", "$dataWinBak", "--code") + $replaceFiles + @("-o", "$dataWin")
    & "$pathUMTCLI" @replaceArgs | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-MessageParts "Error" @(
            @{ text = "Error replacing code files. Exiting." }
        )
        Pop-Location
        exit 1
    }
    Pop-Location
    Write-MessageParts "OK" @(
        @{ text = "Patched data.win successfully updated." }
    )
}

# ============================
# MAIN EXECUTION
# ============================
$gamePath   = Get-GamePath
$backupInfo = Backup-Datawin -gamePath $gamePath

$patchFile    = Join-Path $config.PathPatch $config.PatchFileName
$filesToPatch = Get-FilesToPatch -patchFilePath $patchFile

# Create dump files list by removing the .gml extension from each file.
$dumpFiles = $filesToPatch | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) }

$pathUMTCLI = Get-UMTCLI

$codeDumpDir = Dump-CodeFiles -dataWinBak $backupInfo.DataWinBak -dumpFiles $dumpFiles -pathUMTCLI $pathUMTCLI

# Use "CodeEntries" subfolder if it exists.
if (Test-Path (Join-Path $codeDumpDir "CodeEntries")) {
    $dumpBaseDir = Join-Path $codeDumpDir "CodeEntries"
    Write-MessageParts "OK" @(
        @{ text = "Code files are located in: " },
        @{ text = (Format-Path $dumpBaseDir) }
    )
} else {
    $dumpBaseDir = $codeDumpDir
}

Initialize-GitRepo -dumpBaseDir $dumpBaseDir
Apply-Patch -dumpBaseDir $dumpBaseDir -patchFile $patchFile
Replace-CodeFiles -dumpBaseDir $dumpBaseDir -dataWinBak $backupInfo.DataWinBak -filesToPatch $filesToPatch -pathUMTCLI $pathUMTCLI -dataWin $backupInfo.DataWin

Write-MessageParts "OK" @(
    @{ text = "Trainer mod patch applied successfully!" }
)


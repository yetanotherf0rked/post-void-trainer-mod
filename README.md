# Post Void trainer mod

## Features

* Adds a "Trainer" menu in the settings
  * **Start on level**: Instead of starting on level 1, you can start your runs on any other level (Tutorial currently broken)
  * **Loop level**: When finishing the current level, restart that same level again and stop the run progression (useful for ILs, practice)
  * **Force upgrade**: Select an upgrade to always be given as a first choice at the end of every level (until picked if non-stackable)
  * **Start with upgrade**: Start immediately with force upgrade, instead of having to pick it at the end of the level. Currently only works after the first death/suicide (useful for ILs, practice)
* Debug mode enabled
  * Press `l` to exit toggle debug mode
  * FPS counter
  * Press `n` on the keyboard to skip to the next level
  * Press `p` to regenerate life and see some debug info
  * Press `o` to see a debug message
  * Press `Alt` to see some debug info
  * Prevents leaderboards submissions

## Installation

### Pre-requirements

* **[UndertaleModCLI](https://github.com/UnderminersTeam/UndertaleModTool/releases/tag/bleeding-edge)** *will be downloaded automatically if not found in `UMT_CLI`*
* **[git](http://git-scm.com/download/win)** to apply the mod's diffs
* **Post Void version 1.0.3b**: This Trainer Mod is built for Post Void version 1.0.3b. If you're on a different version, follow the downgrade instructions below.
* **PowerShell:** The installation script is a PowerShell script, so make sure you're running it on a compatible Windows system.

### Manual install
- Clone this repo
- Launch the `install.ps1` script

### What the script does 
- If not found, download UndertaleModCLI.exe from [UndertaleModTool's Bleeding Edge assets](https://github.com/UnderminersTeam/UndertaleModTool/releases/tag/bleeding-edge)
- Perform necessary checksums and paths checks
- Dump the patched files found in `trainer_mod.patch` from the game files.

### Downgrading Post Void
1. Press `Win + R` to open the console
```
steam://open/console
```
2. Download the 1.0.3b manifest
```
download_depot 1285670 1285671 8036901950432469698
```
3. Copy the files from `C:\Program Files (x86)\Steam\steamapps\content\app_1285670\depot_1285671` to `C:\Program Files (x86)\Steam\steamapps\common\Post Void`

Visit [this page](https://steamdb.info/depot/1285671/manifests/) for more information.

## Further improvements
- Will work on 1.4c as soon as there's a functional compiler/decompiler for it.

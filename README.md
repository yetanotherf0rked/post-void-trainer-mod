# Post Void Trainer Mod

A trainer for Post Void 1.4c
![image](https://github.com/user-attachments/assets/571ed8ef-7e5a-49af-8128-a8fa924c9ab4)

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

* **[git](http://git-scm.com/download/win)** to apply the mod's diffs
* **[UndertaleModCLI](https://github.com/UnderminersTeam/UndertaleModTool/)** *will be downloaded automatically if not found in `UMT_CLI`*
* **Post Void 1.4c**: This trainer is for version 1.4c. If you want the trainer for the 1.0.3b version, check [this commit](https://github.com/nmussy/post-void-trainer-mod/commit/0ac6b33477203fa270094073ebb398d09473b763).
* **PowerShell:** The installation script is a PowerShell script, so make sure you're running it on a compatible Windows system.

### Manual install
- Clone this repo anywhere, game will be checked for in the default path, you can specify it if not found.
- Launch the install script using `.\install.ps1`.

### What the script does 
- If not found in `UMT_CLI\`, the script suggests you to download and extract UndertaleModCLI.exe from [this PR]([https://github.com/UnderminersTeam/UndertaleModTool/releases/tag/bleeding-edge](https://github.com/UnderminersTeam/UndertaleModTool/pull/2056))
> **Note:** This PR from UndertaleModTool uses the Underanalyzer Compiler and Decompiler, rather than the traditional ones from UMT as I encountered issues with them.
- Perform necessary checksums and paths checks, saves a backup file of `data.win`.
- Dump the patched files found in `trainer_mod.patch` from the game files.
- Applies the patch `trainer_mod.patch` to the dumped files using git.
- Replaces the files and rebuilds `data.win`.

## Known Issues
- Debug Mode is broken in Tutorial.

## Thanks
Thanks to [nmussy](https://github.com/nmussy/), space_core_0352 and [colinator27](https://github.com/colinator27) from the UMT Discord for their help.

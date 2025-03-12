# Post Void Trainer Mod

A trainer for Post Void 1.4c

<img src="https://github.com/user-attachments/assets/c2c43815-35cf-45df-9521-9444e7efae90" width="500" alt="Open the Debug Menu using 'M'" />
<img src="https://github.com/user-attachments/assets/5aa0e4ea-6174-41b6-a9a6-1b2d4a8ed06d" width="500" alt="You can set training parameters in the Settings" />

## Features

* Adds a "Trainer" menu in the settings
  * **Start on level**: Instead of starting on level 1, you can start your runs on any other level (Tutorial currently broken)
  * **Loop level**: When finishing the current level, restart that same level again and stop the run progression (useful for ILs, practice)
  * **Force upgrade**: Select an upgrade to always be given as a first choice at the end of every level (until picked if non-stackable)
  * **Start with upgrade**: Start immediately with force upgrade, instead of having to pick it at the end of the level. Currently only works after the first death/suicide (useful for ILs, practice)
* Open the Debug mode by pressing `m`. Inside the debug mode you can:
  * Press `l` to activate god mode (no death countdown when no HP left)
  * Press `n` to skip to the next level
  * Press `k` to suicide
  * Press `p` to regenerate 20% life
  * Press `Alt` to see colorimetry info
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
- If not found in `UMT_CLI\`, the script suggests you to download and extract UndertaleModCLI.exe from [this PR](https://github.com/UnderminersTeam/UndertaleModTool/pull/2056).
> **Note:** This PR from UndertaleModTool uses the Underanalyzer Compiler and Decompiler, rather than the traditional ones from UMT as I encountered issues with them.
- Perform necessary checksums and paths checks, saves a backup file of `data.win`.
- Dump the patched files found in `trainer_mod.patch` from the game files.
- Applies the patch `trainer_mod.patch` to the dumped files using git.
- Replaces the files and rebuilds `data.win`.

## Known Issues
- Debug Mode is broken in Tutorial.

## Further improvements
If I find time to implement these:
- fix the Level Times to display the correct level when starting with a different level or looping through a level
- add a feature to get stats such as: `average_speed`, `bumps_into_walls`, `bumps_into_enemies`, `number_of_hits_by_enemies`, `average_time_before_dashing`, `number_of_dashes`, `level_success_ratio`

## Thanks
Thanks to [nmussy](https://github.com/nmussy/), space_core_0352 and [colinator27](https://github.com/colinator27) from the UMT Discord for their help.

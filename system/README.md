# System configuration files for ZSH

This directory contains system-wide configuration files for ZSH. These files are typically sourced by the ZSH shell when it starts up, allowing you to set environment variables, aliases, functions, and other settings that apply to all users on the system

It also supports specific configurations per operating system

- `aliases.sh` - Aliases for commands
- `bundles.sh` - Plugins to load
- `environment.sh` - Environment variables
- `functions.sh` - Custom functions

All of these files also can have a variation that is ignored by **git**. Use those files to store functions that you do not want to share with others, such as personal aliases or functions that are specific to your environment

- `aliases.local.sh` - Local aliases for commands
- `bundles.local.sh` - Local plugins to load
- `environment.local.sh` - Local environment variables
- `functions.local.sh` - Local custom functions

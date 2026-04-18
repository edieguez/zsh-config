# zsh-config

A personal zsh configuration built on top of [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh). Cross-platform (macOS and Linux), modular, and designed so machine-specific tweaks stay out of version control.

Once installed, the repo lives at `~/.zsh/zsh-config/` alongside `~/.zsh/ohmyzsh/`, and `system/zshrc` is symlinked to `~/.zshrc`.

## Installation

Run the installer — it clones `ohmyzsh`, this repo, and [`fast-syntax-highlighting`](https://github.com/zdharma-continuum/fast-syntax-highlighting) into `~/.zsh/`, then symlinks `system/zshrc` to `~/.zshrc`:

```shell
wget -qO - https://raw.githubusercontent.com/edieguez/zsh-config/master/system/install.sh | zsh
```

Restart your shell (or `exec zsh`) to finish setup.

Optional but recommended tools — this config activates extra features when it detects them on `PATH`:

- [`fzf`](https://github.com/junegunn/fzf) + [`fd`](https://github.com/sharkdp/fd) — fuzzy file/dir navigation (`CTRL-T`, `ALT-C`)
- [`bat`](https://github.com/sharkdp/bat) — richer fzf preview (falls back to `cat`)
- [`nvm`](https://github.com/nvm-sh/nvm) at `~/.nvm` — enables lazy-loaded Node
- [`sdkman`](https://sdkman.io/) at `~/.sdkman` — enables lazy-loaded JVM tooling

## How to add plugins

Plugins are oh-my-zsh plugins, and they must be declared **before** oh-my-zsh is sourced.

**Always-on plugins** — edit the `plugins=(...)` array in [`system/zshrc`](system/zshrc):

```zsh
plugins=(
    extract
    sudo
    virtualenv_py
    z
    fast-syntax-highlighting
    my-new-plugin          # <-- add here
)
```

**Conditional plugins** (load only if a tool is installed) — append to `plugins` from [`system/bundles.sh`](system/bundles.sh), following the existing patterns:

```zsh
(( $+commands[docker] )) && plugins+=(docker)
[ -d "$HOME/.my-tool" ] && plugins+=(my-tool-plugin)
```

**Custom plugins** (code you wrote or cloned yourself) — drop the plugin directory under [`plugins/`](plugins/) and add its name to the `plugins=(...)` array. This directory acts as `$ZSH_CUSTOM/plugins`, so oh-my-zsh picks them up automatically.

**Platform-specific plugins** — use `system/macos/bundles.sh` or `system/linux/bundles.sh` (loaded right after the global `bundles.sh`).

## How to add paths to `PATH`

`PATH` precedence, from highest to lowest, is set at the end of `system/zshrc`:

```shell
bin/local  >  bin/$PLATFORM  >  bin/  >  CUSTOM_PATH  >  system $PATH
```

Pick the right spot based on what you're adding:

**A script you want available as a command** — drop it in one of the `bin/` directories and make it executable (`chmod +x`). It's on `PATH` automatically:

| Where                      | When to use                                                           |
| -------------------------- | --------------------------------------------------------------------- |
| [`bin/`](bin/)             | Cross-platform scripts, committed to the repo                         |
| [`bin/macos/`](bin/macos/) | macOS-only scripts                                                    |
| [`bin/linux/`](bin/linux/) | Linux-only scripts                                                    |
| `bin/local/`               | Machine-specific scripts or binaries (gitignored, highest precedence) |

Note: `bin/` is added to `PATH` non-recursively. Subdirectories like `bin/archive/` are not on `PATH`.

**A toolchain directory** (like `$GOROOT/bin` or a language version manager) — extend `CUSTOM_PATH` in [`system/environment.sh`](system/environment.sh):

```zsh
export CUSTOM_PATH="$CARGO_HOME/bin:$GOROOT/bin:$GOPATH/bin:$HOME/.my-tool/bin"
```

**A path that shouldn't be committed** (private tool, work-specific directory) — export it from `system/environment.local.sh` (see next section).

## Machine-specific configurations (local files)

Every `system/*.sh` file has a `*.local.sh` counterpart that is **gitignored and loaded after the global one**. Use these for anything you don't want to commit: API keys, machine-specific aliases, per-host function overrides, etc.

| Local file                    | Purpose                                 |
| ----------------------------- | --------------------------------------- |
| `system/environment.local.sh` | Env vars, secrets, extra `PATH` entries |
| `system/bundles.local.sh`     | Plugins only installed on this machine  |
| `system/aliases.local.sh`     | Personal aliases                        |
| `system/functions.local.sh`   | Personal functions                      |

Example `system/environment.local.sh`:

```zsh
export OPENAI_API_KEY="sk-..."
export WORK_VPN_HOST="vpn.example.com"
export PATH="$HOME/work/tools/bin:$PATH"
```

For private binaries and scripts, use `bin/local/` — also gitignored, and highest `PATH` precedence.

These files are created as needed; nothing expects them to exist. Missing `*.local.sh` files and the `bin/local/` directory are silently skipped.

## Layout

```shell
~/.zsh/
├── ohmyzsh/                        cloned by install.sh
└── zsh-config/                     this repo (= $ZSH_CUSTOM)
    ├── system/
    │   ├── zshrc                   entry point, symlinked to ~/.zshrc
    │   ├── environment.sh          env vars, FZF defaults, CUSTOM_PATH
    │   ├── bundles.sh              conditional plugins, lazy-loads
    │   ├── aliases.sh              global aliases
    │   ├── functions.sh            global functions
    │   ├── install.sh              installer
    │   ├── macos/                  macOS-specific overrides
    │   └── linux/                  Linux-specific overrides
    ├── bin/                        scripts auto-added to PATH
    ├── lib/                        sourced helper libraries
    ├── plugins/                    custom oh-my-zsh plugins
    └── themes/                     custom oh-my-zsh themes (default: aya)
```

Load order on every shell start: `environment` → `bundles` → oh-my-zsh core → `aliases` → `functions` → `PATH`. Each step loads the global file, then the platform variant, then the `*.local.sh` override (if present).

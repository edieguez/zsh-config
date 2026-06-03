# virtualenv_py

Custom oh-my-zsh plugin for managing Python virtual environments stored in a central directory.
Wraps `python3 -m venv` with auto-detection, baseline package installation, and tab completion for
environment names.

---

## Contents

- [Dependencies](#dependencies)
- [Commands](#commands)
- [Tab completion](#tab-completion)
- [Configuration](#configuration)

---

## Dependencies

| Tool | Role | Required |
|------|------|:--------:|
| `python3` | Creates virtual environments via `-m venv` | ✓ |

The Python executable is configurable via `PYTHON_COMMAND` — see [Configuration](#configuration).

---

## Commands

### `activate [name]`

Activates a virtual environment by name. If the environment does not exist it is created first.

```zsh
activate myproject       # activate (or create) ~/.virtualenvs/myproject
activate                 # auto-detect name from the current directory (see below)
```

**Auto-detection** — when called without an argument, the plugin checks whether the current
directory contains a `requirements.txt`, `pyproject.toml`, or `setup.py`. If any of these is found,
the environment name is set to the current directory's basename.

```zsh
cd ~/projects/myproject  # contains requirements.txt
activate                 # equivalent to: activate myproject
```

**New environment setup** — on first creation the plugin installs a baseline set of packages before
touching any requirements file:

| Package | Purpose |
|---------|---------|
| `pip` (upgraded) | Ensures the latest installer is used |
| `autopep8` | Code formatting |
| `ipython` | Enhanced interactive interpreter |
| `$VENV_EXTRA_PACKAGES` | Any extra packages configured via the environment variable |

It then looks for a project requirements file and installs from the first one found, in this order:

1. `requirements.txt`
2. `pyproject.toml`
3. `setup.py`

### `deactivate`

Deactivates the currently active environment. Prints an error if no environment is active.

```zsh
deactivate
```

---

## Tab completion

`activate` supports tab completion for environment names. Candidates are all directories inside
`VENV_HOME`.

```zsh
activate my<Tab>    # completes from ~/.virtualenvs/my*
```

---

## Configuration

All variables use the `: ${VAR=default}` syntax — they are only set if not already defined, so they
can be overridden in `system/environment.local.sh` (gitignored) without editing this plugin.

| Variable | Default | Description |
|----------|---------|-------------|
| `VENV_HOME` | `~/.virtualenvs` | Directory where all virtual environments are stored |
| `PYTHON_COMMAND` | `python3` | Python executable used to create environments |
| `VENV_EXTRA_PACKAGES` | _(empty)_ | Space-separated list of extra packages installed on every new environment |

Example overrides in `system/environment.local.sh`:

```zsh
export VENV_HOME="$HOME/.venvs"
export PYTHON_COMMAND="python3.12"
export VENV_EXTRA_PACKAGES="black ruff pytest"
```

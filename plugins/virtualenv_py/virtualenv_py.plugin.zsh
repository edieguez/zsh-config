: ${VENV_HOME=$HOME/.virtualenvs}
: ${PYTHON_COMMAND=python3}
: ${VENV_EXTRA_PACKAGES=}

activate() {
    local venv_name=$1

    if [ -z "$venv_name" ] && [ -f 'requirements.txt' -o -f 'pyproject.toml' -o -f 'setup.py' ]; then
        venv_name=$(basename "$PWD")
    fi

    if [ -z "$venv_name" ]; then
        echo $'\e[01;31m[i] Error: Missing argument. Provide a Python environment name.\e[0m'
        return 1
    fi

    if [ -d "$VENV_HOME/$venv_name" ]; then
        echo $'\e[01;34m'"[i] Activating existing environment: $venv_name"$'\e[0m'
        source "$VENV_HOME/$venv_name/bin/activate"
    else
        echo $'\e[01;34m'"[i] Creating and activating virtual environment: $venv_name"$'\e[0m'
        $PYTHON_COMMAND -m venv "$VENV_HOME/$venv_name"
        source "$VENV_HOME/$venv_name/bin/activate"

        $PYTHON_COMMAND -m pip install -U pip autopep8 ipython ${=VENV_EXTRA_PACKAGES}

        for requirements_file in requirements.txt pyproject.toml setup.py; do
            if [ -f "$requirements_file" ]; then
                echo $'\e[01;34m'"[i] Installing packages from $requirements_file"$'\e[0m'
                $PYTHON_COMMAND -m pip install -r "$requirements_file"
                break
            fi
        done
    fi
}

deactivate() {
    if [ -z "$VIRTUAL_ENV" ]; then
        echo $'\e[01;31m[i] No active virtual environment.\e[0m'
        return 1
    fi
    builtin deactivate 2>/dev/null || command deactivate
}

_virtualenv_py() {
    local -a venv_names
    venv_names=($VENV_HOME/*(/N:t))
    _describe 'virtual environments' venv_names
}

compdef _virtualenv_py activate

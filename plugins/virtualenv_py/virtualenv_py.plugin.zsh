: ${VENV_HOME=$HOME/.virtualenvs}
: ${PYTHON_COMMAND=python3}

activate() {
    local venv_name=$1
    local requirements_file='requirements.txt'
    [ -z $venv_name -a -f $requirements_file ] && venv_name=$(basename "$PWD")

    if [ -z "$venv_name" ]; then
        echo '[01;31m[i] Error: Missing argument. Provide a Python environment name.[0m'
        return 1
    fi

    if [ -d "$VENV_HOME/$venv_name" ]; then
        source "$VENV_HOME/$venv_name/bin/activate"
    else
        echo "[01;34m[i] Creating and activating virtual environment: $venv_name[0m"
        $PYTHON_COMMAND -m venv "$VENV_HOME/$venv_name"
        source "$VENV_HOME/$venv_name/bin/activate"

        $PYTHON_COMMAND -m pip install -U pip autopep8 ipython

        if [ -f $requirements_file ]; then
            echo "[01;34m[i] Installing packages from $requirements_file[0m"
            $PYTHON_COMMAND -m pip install -r $requirements_file
        fi
    fi
}

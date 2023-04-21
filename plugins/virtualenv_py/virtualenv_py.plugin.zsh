: ${VENV_HOME=$HOME/.virtualenvs}
: ${PYTHON_COMMAND=python3}

activate() {
    local venv_name=$1

    if [ -f 'requirements.txt' -a -z "$venv_name" ]; then
        venv_name=$(basename $(pwd))

        if [ ! -d $VENV_HOME/$1 ]; then
           echo "Creating $venv_name virtualenv with requirements.txt"
        fi
    fi

    virtualenv $venv_name && source $VENV_HOME/$venv_name/bin/activate
}

virtualenv() {
    if [ $# = 0 ]; then
        echo 'Missing argument: Python environment name is required'
        return 1
    fi

    [ ! -d $VENV_HOME -o ] && mkdir -v $VENV_HOME

    if [ ! -d $VENV_HOME/$1 ]; then
        $PYTHON_COMMAND -m venv $VENV_HOME/$1

        source $VENV_HOME/$1/bin/activate
        $PYTHON_COMMAND -m pip install -U pip autopep8 ipython

        if [ -f 'requirements.txt' ]; then
            echo 'Installing requirements.txt'
            $PYTHON_COMMAND -m pip install -r 'requirements.txt'
        fi

        deactivate
    fi
}

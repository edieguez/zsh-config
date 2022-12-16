: ${VENV_HOME=$HOME/.virtualenvs}
: ${PYTHON_COMMAND=python3}

activate() {
    virtualenv $1 && source $VENV_HOME/$1/bin/activate
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

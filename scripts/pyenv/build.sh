#!/bin/bash

# abort on errors
set -e


# get root directories of frost build script
REPO_ROOT="$(dirname "$(dirname "$(cd "$(dirname "$0")"; pwd)")")"


# setup directories
PYENV_ROOT="$REPO_ROOT/temp.build/pyenv"


# need to create?
if [ ! -f "$PYENV_ROOT/install_done" ]; then

    # what are we doing
    echo "Building Python environment."

    # create new temporary build directory
    if [ ! -f "$PYENV_ROOT/install_done" ]; then
        rm -rf "$PYENV_ROOT"
    fi
    mkdir -p "$(dirname $PYENV_ROOT)"
    pushd "$(dirname $PYENV_ROOT)"

    # create default python venv and load it
    python3 -m venv pyenv
    popd
    if [ -f "$PYENV_ROOT/Scripts/activate" ]; then
        source "$PYENV_ROOT/Scripts/activate"
    else
        source "$PYENV_ROOT/bin/activate"
    fi

    # setup python environment
    python3 -m pip install ninja
    python3 -m pip install meson

    # move to install directory
    touch "$PYENV_ROOT/install_done"

    echo "Python environment created."

else

    echo "Python environment already created."

fi

#!/bin/bash

# abort on errors
set -e

# get root directories of frost build script
REPO_ROOT="$(dirname "$(dirname "$(cd "$(dirname "$0")"; pwd)")")"

# decalre python sources
PYTHON_URL="https://github.com/python/cpython.git"
PYTHON_VERSION="v$( python3 package.py version )"

# declare pathes to python source installation
PYTHON_SRC_DIR="$REPO_ROOT/temp.build/src-python"
PYTHON_BUILD_DIR="$REPO_ROOT/temp.build/build-python"
PYTHON_INSTALL_DIR="$REPO_ROOT/temp.build/build-install"

# build python virtual environment and use it
$REPO_ROOT/scripts/pyenv/build.sh
PYENV_ROOT="$REPO_ROOT/temp.build/pyenv"
if [ -f "$PYENV_ROOT/Scripts/activate" ]; then
    source "$PYENV_ROOT/Scripts/activate"
else
    source "$PYENV_ROOT/bin/activate"
fi

# recreate temporary download
echo "Clean temporary source directory"
if [ -d "$PYTHON_SRC_DIR" ]; then
    rm -rf $"$PYTHON_SRC_DIR"
fi
mkdir -p "$PYTHON_SRC_DIR"

# fetch cypthon repository
echo "Fetch cpython sources"
pushd "$PYTHON_SRC_DIR" > /dev/null
    git clone --depth 1 --branch "$PYTHON_VERSION" "$PYTHON_URL" .
popd > /dev/null

# recreate temporary build directory
echo "Clean temporary build directory"
if [ -d "$PYTHON_BUILD_DIR" ]; then
    rm -rf $"$PYTHON_BUILD_DIR"
fi
mkdir -p "$PYTHON_BUILD_DIR"

# recreate temporary installation directory
echo "Clean temporary build directory"
if [ -d "$PYTHON_BUILD_DIR" ]; then
    rm -rf $"$PYTHON_BUILD_DIR"
fi
mkdir -p "$PYTHON_BUILD_DIR"

# build python
pushd "$PYTHON_BUILD_DIR" > /dev/null
if [[ "$BUILD_TARGET" == win-* ]]; then
    echo "TODO:"
    exit 1
else
    $PYTHON_SRC_DIR/configure --prefix="$PYTHON_INSTALL_DIR" --enable-optimizations --with-lto 
    make -j$BUILD_CPU_CORES
    make install
fi
popd > /dev/null

# create package
if [[ "$BUILD_TARGET" == win-* ]]; then
    echo "TODO:"
    exit 1
else
    if [ ! -d "artifacts" ]; then
        mkdir -p "artifacts"
    fi
    ARCHIVE_NAME="python-$BUILD_VERSION-$BUILD_TARGET"
    ABS_ARCHIVE="artifacts/$ARCHIVE_NAME.tar.bz2"
    if [ ! -f "$ABS_ARCHIVE" ]; then
        echo "Building archive $ABS_ARCHIVE"
        pushd "$CLANG_INSTALL_DIR"
        tar -cjf "$ABS_ARCHIVE" *
        popd
    fi
fi

# TODO: install python

# TODO: package description

# TODO: package license

# TODO: package python

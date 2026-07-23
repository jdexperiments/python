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
if [ -d "$PYTHON_INSTALL_DIR" ]; then
    rm -rf $"$PYTHON_INSTALL_DIR"
fi
mkdir -p "$PYTHON_INSTALL_DIR"

# build python
if [[ "$BUILD_TARGET" == win-* ]]; then
    pushd "$PYTHON_SRC_DIR" > /dev/null
    if [ "$BUILD_TARGET" = "win-x86_64" ]; then
        PPF="x64"
        TEMP_INSTALL="$PYTHON_SRC_DIR/PCbuild/amd64"
    elif [ "$BUILD_TARGET" = "win-arm64" ]; then
        PPF="arm64"
        TEMP_INSTALL="$PYTHON_SRC_DIR/PCbuild/arm64"
    else
        echo "failed: unknown target"
        exit 1
    fi
    ./PCbuild/build.bat -e -p $PPF -c Release
    TEMP_INSTALL_WIN="$(cygpath -w "$TEMP_INSTALL")"
    TARGET_INSTALL_WIN="$(cygpath -w "$PYTHON_INSTALL_DIR")"
    echo "create directory layout..."
    export PYTHONINCLUDE="$PYTHON_SRC_DIR/Include"
    python3 PC/layout/main.py --build "$TEMP_INSTALL_WIN" --source . --copy "$TARGET_INSTALL_WIN" --preset-default
    popd > /dev/null
else
    pushd "$PYTHON_BUILD_DIR" > /dev/null
    $PYTHON_SRC_DIR/configure --prefix="$PYTHON_INSTALL_DIR" --enable-optimizations --with-lto 
    make -j$BUILD_CPU_CORES
    make install
    popd > /dev/null
    TEMP_INSTALL="$PYTHON_INSTALL_DIR"
fi

# copy license file to artifacts
cp "$PYTHON_SRC_DIR/LICENSE" "$TEMP_INSTALL/LICENSE.python-$BUILD_VERSION"

# TODO: add manifest

# create package
if [ ! -d "artifacts" ]; then
    mkdir -p "artifacts"
fi
ARCHIVE_NAME="python-$BUILD_VERSION-$BUILD_TARGET"
ABS_ARCHIVE="$(cd artifacts && pwd)/$ARCHIVE_NAME.tar.bz2"
if [ ! -f "$ABS_ARCHIVE" ]; then
    echo "Building archive $ABS_ARCHIVE"
    pushd "$PYTHON_INSTALL_DIR" > /dev/null
    tar -cjf "$ABS_ARCHIVE" *
    popd > /dev/null
fi

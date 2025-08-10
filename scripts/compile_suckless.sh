#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pushd "$SCRIPT_DIR/../dot-local/src/" > /dev/null
build_tool() {
    local tool=$1
    pushd "$tool" > /dev/null
        if sudo make clean install > /dev/null 2>&1; then
            echo -e "[\e[32mOK\e[0m] $tool compiled and installed successfully."
        else
            echo -e "[\e[31mFAIL\e[0m] $tool compilation or installation failed."
        fi
    popd > /dev/null
}

build_tool dwm
build_tool st
build_tool dmenu
build_tool slock

popd > /dev/null

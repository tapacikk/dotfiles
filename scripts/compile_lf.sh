#!/bin/bash
set -e

# Root check
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31m[FAIL]\033[0m This script must be run as root."
    exit 1
fi

build_program() {
    local name="$1"
    local url="$2"
    local version="$3"
    local base="/opt/$name"
    local tar_dir="$base/tarballs"
    local src_dir="$base/src"
    local prefix="$base/$version"

    mkdir -p "$tar_dir" "$src_dir" "$prefix"

    echo -e "\033[0;32m[INFO]\033[0m Downloading $name..."
    local tarball="$tar_dir/${url##*/}"
    curl -L "$url" -o "$tarball"

    echo -e "\033[0;32m[INFO]\033[0m Extracting $name..."
    rm -rf "$src_dir"/*
    tar -xf "$tarball" -C "$src_dir"

    # Custom build logic per program
    if [ "$name" == "ctpv" ]; then
        echo -e "\033[0;33m[BUILD]\033[0m Custom build for ctpv..."
        pushd "$src_dir/ctpv-$version" > /dev/null
        make PREFIX="$prefix" install
        popd > /dev/null

    elif [ "$name" == "ueberzugpp" ]; then
        echo -e "\033[0;33m[BUILD]\033[0m Custom build for ueberzugpp..."
        mkdir -p "$src_dir/ueberzugpp-$version/build"
        pushd "$src_dir/ueberzugpp-$version/build" > /dev/null
        cmake .. -DCMAKE_INSTALL_PREFIX="$prefix"
        make -j"$(nproc)" install
        popd > /dev/null

    else
        echo -e "\033[0;31m[FAIL]\033[0m No build instructions for $name"
        exit 1
    fi
}

main() {
    build_program "ueberzugpp" \
        "https://github.com/jstkdng/ueberzugpp/archive/refs/tags/v2.9.6.tar.gz" \
        "2.9.6"

    build_program "ctpv" \
        "https://github.com/NikitaIvanovV/ctpv/archive/refs/tags/v0.6.4.tar.gz" \
        "0.6.4"

    echo -e "\n\033[0;32m[OK]\033[0m All programs built successfully."
}

main "$@"

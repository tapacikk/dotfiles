#!/bin/bash
#

BUILD_DIR="/opt"


get_mons() {
    git clone --recursive https://github.com/Ventto/mons.git $BUILD_DIR/mons
}

install_mons() {
    cd "$BUILD_DIR/mons"
    sudo make install
}


main() {
    echo -e "\n=== Installing mons ==="
    sudo rm -r "$BUILD_DIR/mons"
    sudo mkdir -p "$BUILD_DIR/mons"
    sudo chown -R $USER:$USER "$BUILD_DIR/mons"
    get_mons
    install_mons
    echo -e "\033[0;32m[OK]\033[0m Installed mons"
}

main "$@"

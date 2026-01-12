#!/bin/bash
set -e


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

VIM_VERSION="v9.1.1989"
BUILD_DIR="/opt"
INSTALL_PREFIX="/usr/local"

ok()    { echo -e "\033[0;32m[OK]\033[0m $1"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $1"; }
fail()  { echo -e "\033[0;31m[FAIL]\033[0m $1"; exit 1; }

check_deps() {
    local deps=(git make gcc libx11-dev xserver-xorg-dev xorg-dev) missing=()
    for dep in "${deps[@]}"; do
        if ! command -v "${dep%%-dev}" &>/dev/null && ! dpkg -l | grep -q "$dep" 2>/dev/null; then
            missing+=("$dep")
        fi
    done
    [ ${#missing[@]} -eq 0 ] || { fail "Missing: ${missing[*]}. Install: sudo apt-get install ${missing[*]}"; }
}

get_vim() {
    rm -rf "$BUILD_DIR/vim"
    git clone --depth 1 --branch "$VIM_VERSION" https://github.com/vim/vim.git "$BUILD_DIR/vim"
}

get_plugins() {
    local dir="$BUILD_DIR/vim/runtime/pack/dist/start"
    mkdir -p "$dir"
    git clone --depth 1 https://github.com/preservim/nerdtree.git "$dir/nerdtree"
    git clone --depth 1 https://github.com/vimwiki/vimwiki.git "$dir/vimwiki"
    git clone --depth 1 https://github.com/sainnhe/everforest.git "$dir/everforest"
    git clone --depth 1 https://github.com/ervandew/supertab.git "$dir/supertab"
    git clone --depth 1 https://github.com/itchyny/lightline.vim "$dir/lightline"
    git clone --depth 1 https://github.com/ryanoasis/vim-devicons.git "$dir/devicons"
    find "$dir" -name .git -type d -exec rm -rf {} +
    rm -r "$dir/vimwiki/test/resources/testwiki space" 2>/dev/null || true
}

build_vim() {
    cd "$BUILD_DIR/vim"
    make distclean 2>/dev/null || true
    ./configure --prefix="$INSTALL_PREFIX" \
        --with-features=normal \
        --enable-multibyte \
        --disable-netbeans \
        --without-x \
        --disable-gui \
        --without-wayland \
        --disable-mouse \
        --disable-gtk2-check \
        --disable-gtk3-check \
        --disable-gnome-check \
        --disable-motif-check \
        --disable-athena-check \
        --enable-python3interp=yes \
        --with-python3-config-dir=$(python3-config --configdir) 

    make -j
}

install_vim() {
    cd "$BUILD_DIR/vim"
    [ -w "$INSTALL_PREFIX" ] && make install || sudo make install
}

verify() {
    command -v vim &>/dev/null || fail "Vim not found after install"
    ok "$(vim --version | head -n1)"
    vim --version | grep -q "+clipboard" && ok "Clipboard ✓" || warn "Clipboard ✗"
    vim --version | grep -q "+python"    && ok "Python ✓"
}

main() {
    echo -e "\n=== Building Vim $VIM_VERSION ==="
    check_deps
    mkdir -p "$BUILD_DIR"
    get_vim
    get_plugins
    build_vim
    install_vim
    verify
    ok "Vim build complete!"
}

main "$@"

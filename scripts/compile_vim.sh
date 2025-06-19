#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
VIM_VERSION="v9.1.0"
BUILD_DIR="/tmp/vim-build"
INSTALL_PREFIX="/usr/local"

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    print_status "Checking dependencies..."
    
    local deps=("git" "make" "gcc" "libncurses5-dev" "libncursesw5-dev" "libx11-dev" "xserver-xorg-dev" "xorg-dev")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "${dep%%-dev}" &> /dev/null && ! dpkg -l | grep -q "$dep" 2>/dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing[*]}"
        print_status "Install with: sudo apt-get install ${missing[*]}"
        exit 1
    fi
}

cleanup_previous() {
    if [ -d "$BUILD_DIR" ]; then
        print_warning "Removing previous build directory..."
        rm -rf "$BUILD_DIR"
    fi
}

download_vim() {
    print_status "Downloading Vim source code..."
    git clone --depth 1 --branch "$VIM_VERSION" https://github.com/vim/vim.git "$BUILD_DIR/vim"
}

download_plugins() {
    print_status "Downloading plugins..."
    
    # Create runtime directories
    mkdir -p "$BUILD_DIR/vim/runtime/pack/dist/start"
    
    # Download NERDTree
    print_status "Downloading NERDTree..."
    git clone --depth 1 https://github.com/preservim/nerdtree.git \
        "$BUILD_DIR/vim/runtime/pack/dist/start/nerdtree"
    
    # Download VimWiki
    print_status "Downloading VimWiki..."
    git clone --depth 1 https://github.com/vimwiki/vimwiki.git \
        "$BUILD_DIR/vim/runtime/pack/dist/start/vimwiki"
    
    # Clean up git directories to reduce size
    find "$BUILD_DIR/vim/runtime/pack/dist/start" -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true
    rm -r $BUILD_DIR/vim/runtime/pack/dist/start/vimwiki/test/resources/testwiki\ space
}

configure_vim() {
    print_status "Configuring Vim build..."
    
    cd "$BUILD_DIR/vim"
    
    # Clean any previous configuration
    make distclean 2>/dev/null || true
    
    # Configure with minimal features but include clipboard support
    ./configure \
        --prefix="$INSTALL_PREFIX" \
        --enable-multibyte \
        --enable-pythoninterp=dynamic \
        --enable-python3interp=dynamic \
        --with-features=normal \
        --enable-clipboard \
        --with-x \
        --disable-gui \
        --disable-mouse \
        --disable-gtk2-check \
        --disable-gtk3-check \
        --disable-gnome-check \
        --disable-motif-check \
        --disable-athena-check \
        --disable-netbeans \
        --disable-xsmp \
        --disable-xsmp-interact \
        --with-compiledby="TARAS" \
        --with-tlib=ncurses
}

compile_vim() {
    print_status "Compiling Vim (this may take a few minutes)..."
    
    cd "$BUILD_DIR/vim"
    
    # Use all available cores for compilation
    local cores=$(nproc)
    make -j"$cores"
}

install_vim() {
    print_status "Installing Vim..."
    
    cd "$BUILD_DIR/vim"
    
    # Check if we need sudo for installation
    if [ ! -w "$INSTALL_PREFIX" ]; then
        print_warning "Installing to $INSTALL_PREFIX requires sudo privileges"
        sudo make install
    else
        make install
    fi
}

verify_installation() {
    print_status "Verifying installation..."
    
    if ! command -v vim &> /dev/null; then
        print_error "Vim installation failed - vim command not found"
        exit 1
    fi
    
    local vim_version=$(vim --version | head -n1)
    print_status "Successfully installed: $vim_version"
    
    # Check for clipboard support
    if vim --version | grep -q "+clipboard"; then
        print_status "Clipboard support: ✓ Enabled"
    else
        print_warning "Clipboard support: ✗ Not detected"
    fi
    
    # Check for Python support
    if vim --version | grep -q "+python"; then
        print_status "Python support: ✓ Enabled"
    fi
}

create_basic_vimrc() {
    local vimrc_path="$HOME/.vimrc"
    
    if [ ! -f "$vimrc_path" ]; then
        print_status "Creating basic .vimrc with plugin settings..."
        
        cat > "$vimrc_path" << 'EOF'
set nocompatible
filetype plugin on
set hidden
set incsearch ic wildmenu smartcase
set backspace=indent,eol,start
set cursorline
set nobackup noswapfile
syntax enable
set autoindent expandtab tabstop=4 shiftwidth=4 scrolloff=15
nmap <silent> <c-l> :wincmd l<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-k> :wincmd k<CR>
noremap <C-n> :set nu!<CR>
nnoremap ;w :up<CR>
nnoremap ;q :q<CR>
nnoremap ;s :ls<CR>:b<Space>
nnoremap ;e :e<Space>
nnoremap ;; :
nnoremap 11 :RunHere 
nnoremap ;n :NERDTreeToggle<CR>
let NERDTreeWinSize=20
let NERDTreeMinimalUI=1
let NERDTreeMinimalMenu=1
nnoremap q: <nop>
nnoremap Q <nop>
inoremap kj <Esc>
nnoremap n nzzzv
nnoremap N Nzzzv
set nowrap
command! -nargs=+ RunHere execute 'cd %:p:h' | execute '!'.<q-args>
"STATUSLINE
set laststatus=2
set statusline=
set statusline +=\ b%n\ %*            "buffer number
set statusline +=%=\ %<%F%*            "full path
set statusline +=%m%*                "modified flag
set statusline +=%=%y%*                "file type
set statusline +=%5l%*             "current line
set statusline +=/%L%*               "total lines
set nofoldenable
"VIMWIKI config
let g:vimwiki_list = [{ 'path': '/work/notes/wiki'}]
EOF
        print_status "Created basic .vimrc configuration"
    else
        print_warning ".vimrc already exists, skipping creation"
    fi
}

cleanup() {
    print_status "Cleaning up build directory..."
    rm -rf "$BUILD_DIR"
}

main() {
    echo "=================================================="
    echo "    Custom Vim Compilation Script"
    echo "    Features: NERDTree, VimWiki, Clipboard"
    echo "    No GUI, Minimal Bloat"
    echo "=================================================="
    echo
    
    check_dependencies
    cleanup_previous
    
    mkdir -p "$BUILD_DIR"
    
    download_vim
    download_plugins
    configure_vim
    compile_vim
    install_vim
    verify_installation
    create_basic_vimrc
    
#     Ask before cleanup
    echo
    read -p "Remove build directory? [Y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        cleanup
    fi
    
    echo
    print_status "Vim compilation complete!"
    echo
}

main "$@"

set nocompatible
set hidden
set laststatus=2
inoremap kj <Esc>
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
nnoremap 11 :!
nnoremap <C-t> <C-z>
nnoremap ;n :NERDTreeToggle<CR>
let NERDTreeWinSize=20
let NERDTreeMinimalUI=1
let NERDTreeMinimalMenu=1


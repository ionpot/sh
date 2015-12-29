syntax on

set number
set relativenumber
set ruler

set autoindent
"set fdm=indent

set expandtab
set softtabstop=4
set shiftwidth=4

vn d xi

highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100)

autocmd FileType javascript call JSVC_setup()

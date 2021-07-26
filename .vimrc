let $BASH_ENV = "~/sh/.load-aliases"

set autoindent
"set fdm=indent
set tabstop=4
set shiftwidth=4

vn d xi

"execute pathogen#infect()

"let g:ctrlp_custom_ignore = { "dir": "[_]\\?build\\|node_modules" }

"exclude these directories when generating tags
"let g:gutentags_ctags_exclude = [".git", "_build", "node_modules"]

filetype plugin indent on

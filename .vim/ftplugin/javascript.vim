"syntax on

iab ff function

nnoremap <buffer> ; :w !jslint<CR>

highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100)

"call JSVC_setup()

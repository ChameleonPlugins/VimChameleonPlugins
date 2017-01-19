let g:DEBUG=1

function! Debug(text)
    if g:DEBUG
        echom a:text
    endif
endfunction



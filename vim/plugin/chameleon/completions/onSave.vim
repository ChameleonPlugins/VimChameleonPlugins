
augroup onSave
    autocmd!
    autocmd BufWritePost,FileWritePost,FileAppendPost * call OnSave()
augroup END

function! OnSave()
    "let path = expand('%:p:h')
    let path = "~/.vim/plugin/chameleon/completions/saveScripts/"
    ":echom "path=" . path
    let files = filter(split(globpath(path, '**/*.script'), '\n'),
        \ !'isdirectory(v:val)')
    ":echom "len(files)=" . len(files)
    for file in files
        "echom "file: ".file
        "let short_filename = fnamemodify(file, ":t")
        "let lines = readfile(file)
        :execute ":source " . file
    endfor
endfunction




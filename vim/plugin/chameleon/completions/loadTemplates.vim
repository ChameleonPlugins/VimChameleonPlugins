let g:templates = get(g:, 'templates', [])

function! Add_synonym(synonyms, line)
    "While a:line has ( or ), add w/ & w/o ( & )...
    call add( a:synonyms, a:line)
endfunction

function! LoadTemplates(dir)
    let field = -1
    let REPLACEMENT = 2
"    let fields[] = {'entries', 'hint', 'replacement',
"                \'defaults', 'help', 'tip'}
    let data = []
"    let dir = "~/.vim/plugin/chameleon/completions/templates"
    "let dir = getcwd()
    ":echom "LoadTemplates()"
    let files = filter(split(globpath(a:dir, '**/*.template'), '\n'),
        \ !'isdirectory(v:val)')
    for file in files
        let filetype = "unknown"
        if file =~ "filetype"
            let filetype = substitute(file, ".*\/filetype\/", "", "")
            let filetype = substitute(file, ".*\/", "", "")
        endif
        let short_filename = fnamemodify(file, ":t")
        ":echom "file: %s". file
        let lines = readfile(file)
        let replacement = ""
        let in_replacement = 1
        let in_synonyms = 0
        let current = -1
        let line = ""
        let synonyms = []
        while current < len(lines) -1
            let current = current + 1
            let line = lines[current]
            if line =~ '//\\'
                let field = field + 1
                "echom field
            elseif field ==? 1
                "echom "Add_synonym: " . line
                let filename = short_filename
                "let long_filename = fnamemodify(a:file, ":p")  " expand ~ to /home/USER/
                let home_dir = fnamemodify("~", ":p")  " expand ~ to /home/USER/
                let tilda = ""
                if file =~ home_dir . "chameleon"
                    let tilda = "~"
                endif
                call Add_synonym( synonyms, line . " ==> "
                            \ . data[0] . " [" . tilda . filename . "]" )
                call add(data, "")
            else
                if len(data) < field + 1
                    "echom "add: " . line . " to data[".field."]"
                    if field ==? 0
                        call add(data, line)
                    else
                        call add(data, line . "\n")
                    endif
                else
                    "echom "add+: " . line . " to data[".field."]"
                    let data[field] = data[field] . line . "\n"
                endif
            endif
        endwhile
        "echom "replacement = ". data[REPLACEMENT]
        call add( g:templates,
                    \{'words': synonyms,
                    \'replace': data[REPLACEMENT],
                    \'filetype':  filetype,
                    \'file':  file,
                    \'type': 'template'} )

    endfor
endfunction

:call LoadTemplates("~/chameleon")
:call LoadTemplates("~/.vim/plugin/chameleon/completions/templates")


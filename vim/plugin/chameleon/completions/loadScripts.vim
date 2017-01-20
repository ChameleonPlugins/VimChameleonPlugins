let g:templates = get(g:, 'templates', [])

function! Add_synonym(synonyms, line)
    "While a:line has ( or ), add w/ & w/o ( & )...
    call add( a:synonyms, a:line)
endfunction

function! LoadSnippets()
    let dir = "~/.vim/plugin/chameleon/completions/scripts"
    "let dir = getcwd()
    let files = filter(split(globpath(dir, '**/*.script'), '\n'),
        \ !'isdirectory(v:val)')
    for file in files
        let short_filename = fnamemodify(file, ":t")
        "call Debug(printf("file: %s", file))
        let lines = readfile(file)
        let replacement = ""
        let in_replacement = 1
        let in_synonyms = 0
        let current = 0
        let line = ""
        let synonyms = []
        while current < len(lines) -1
            let current = current + 1
            let line = lines[current]
            if line ==? '"endsnippet'
                let in_replacement = 0
            elseif line ==? '"synonyms'
                let in_synonyms = 1
                "call Debug("in_synonyms = 1")
            elseif in_replacement
                "remove "
                let replacement .= line[1:] . "\n"
                "call Debug("replacement .= " . line)
            elseif line ==? '"endsynonyms'
                let in_synonynms = 0
                ":echom "script: " . file
                call add( g:templates,
                            \{'words': synonyms,
                            \'replace':  replacement,
                            \'file':  file,
                            \'type': 'script'} )
            elseif in_synonyms
                "remove "
                call Add_synonym( synonyms, line[1:])
                "call Debug("synonym=" . line)
            else
                "call Debug("other=" . line)
            endif
        endwhile
    endfor
endfunction


:call LoadSnippets()

let g:templates = get(g:, 'templates', [])

function! Add_synonym(synonyms, line)
    "While a:line has ( or ), add w/ & w/o ( & )...
    call add( a:synonyms, a:line)
endfunction

function! LoadVariables()
    "echom "LoadVariables()"
    let hs = ""
    let dir = expand('%:p:h:h' . hs . ':t')
    let previous_dir = expand('%:p:h' . hs . ':t')
    while dir != '' && dir != 'roles'
        let previous_dir = expand('%:p:h' . hs . ':t')
        let dir = expand('%:p:h:h' . hs . ':t')
        let hs = hs . ':h'
        "echom "dir=".dir
        "echom "p_dir=".previous_dir
    endwhile
    let path = expand('%:p:h:h' . hs)
    "echom "dir=".dir
    "echom "path=".path
    if dir ==? 'roles'
        let full_path = path . "/" . previous_dir . "/defaults/main.yml"
        let parent = expand('%:p' . hs . ":h")
        :call LoadCommonVariables(path,previous_dir)
        if FileExists(full_path)
            let file = full_path
            :call LoadVariablesFor(full_path)
        endif
    endif
endfunction

function! FileExists(path)
    return !empty(glob(a:path))
endfunction

function! LoadCommonVariables(root, current)
"    echom "LoadCommonVariables(".a:root.", ".a:current.")"
    let files = filter(split(globpath(a:root, '*.yml'), '\n'),
        \ !'isdirectory(v:val)')
    for file in files
        "echom "file ".file.":"
        let short_filename = fnamemodify(file, ":t")
        let lines = readfile(file)
        let in_roles = 0
        let found = 0
        let roles = []
        let current = 0
        while current < len(lines) -1
            let current = current + 1
            let line = lines[current]
            if line ==? "  roles:" || line ==? "  pre_tasks:"
                let in_roles = 1
                "echom "in_roles=1"
            elseif in_roles && line[:5] !=? "    - "
                let in_roles = 0
                "echom "in_roles=0"
            elseif in_roles
                let role = line
                let role = substitute(role, "    - include_vars: roles/", "", "")
                let role = substitute(role, "/defaults/main.yml", "", "")
                let role = substitute(role, "/vars/main.yml", "", "")
                let role = substitute(role, "    - ", "", "")
                let role = substitute(role, "{role: ", "", "")
                let role = substitute(role, ",", "", "")
                "echom "role=" . role
                if role ==? a:current
                    let found = 1
                    "echom "FOUND!"
                endif
                call add(roles, role)
            endif
        endwhile
        if found
            for role in roles
                let file = a:root."/roles/".role."/defaults/main.yml"
                if FileExists(file)
                    "echom "LoadVariablesFor(".file.")"
                    :call LoadVariablesFor(file)
                endif
                let file = a:root."/roles/".role."/vars/main.yml"
                if FileExists(file)
                    "echom "LoadVariablesFor(".file.")"
                    :call LoadVariablesFor(file)
                endif
            endfor
            break
        endif
    endfor
    "echom "LoadCommonVariables(".a:root.", ".a:current.")"
endfunction

function! LoadVariablesFor(file)
    "echom "LoadVariables(" . a:file . ")"
    "let files = filter(split(globpath(a:file, '**/*.snippet'), '\n'),
    "    \ !'isdirectory(v:val)')
    "for file in files
    "let short_filename = fnamemodify(a:file, ":t")
    let long_filename = fnamemodify(a:file, ":p")  " expand ~ to /home/USER/
    "call Debug(printf("file: %s", file))
    let lines = readfile(long_filename)
    let replacement = ""
    let in_replacement = 1
    let in_synonyms = 0
    let current = 0
    let tab_length = 0
    let indent_length = 0
    let line = ""
    let keys = []
    let key = ""
    let last_level = 0
    let level = 0
    let item_count = 0
    let synonyms = []
    while current < len(lines) -1
        let current = current + 1
        let line = lines[current]
        "echom "line=" . line
        "ignore comments...
        if ! (line =~? "^#")
            "key:
            if line =~? ":"
                if line =~? " - "
                    let line = substitute(line, "- ", "", "")
                    if item_count <= 0
                        "echom "keys[level=" . level . "]=" . keys[level]
                        let keys[level] = keys[level] . "[" . item_count . "]"
                    else
                        "echom "keys[level-1=" . (0+level-1) . "]=" . keys[level-1]
                        let from = "\[" . (item_count-1) . "\]"
                        let to = item_count
                        let keys[level-1] =
                                    \substitute(keys[level-1], from, to, "")
                    endif
                    let item_count = item_count + 1
                    "echom "item_count=" . item_count
                endif
                let line_array = split(line, ':')
                let key_array = split(line_array[0], " ")
                if len(key_array)>0
                    let key = key_array[0]
                    let indent_length = len(line_array[0]) - len(key)
                endif
                if indent_length > 0
                    if level ==? 0
                        let tab_length = indent_length
                    endif
                    let last_level = level
                    let level = indent_length/tab_length
                    if ( level < last_level )
                        let item_count = 0
                    endif
                else
                    let level = 0
                endif
                "echom "level=" . level
                " key: value
                if len(line_array) > 1
                    let value = line_array[1]
                    let full_key = Get_Full_Key( keys, key, level )
                    let short_filename = fnamemodify(a:file, ":h:h:t")
                    let synonym = "{{ " . full_key . " }} = " . value
                                \ . " [" . short_filename . "]"
                    let replacement = "{{ " . full_key . " }}"
                    call Add_synonym( synonyms, synonym)
                    "echom "> " . synonym . " = " . replacement
                    call add( g:templates,
                                \{'words': synonyms,
                                \ 'replace': replacement,
                                \ 'file': long_filename,
                                \ 'type': 'variable'} )
                    let synonyms = []
                else
                    " key:
                    "   key: value
                    call Add_Key( keys, key, level )
                endif
            endif
        endif
"        elseif line ==? "endsynonyms"
"            let in_synonynms = 0
"            call add( g:templates,
"                        \{'words': synonyms, 'replace':  replacement} )
"        elseif in_synonyms
"            call Add_synonym( synonyms, line)
"        endif
    endwhile
endfunction

function! Add_Key( keys, key, level )
    if len(a:keys) <= a:level
        call add( a:keys, a:key)
    else
        let a:keys[a:level] = a:key
    endif
endfunction

function! Get_Full_Key( keys, key, level )
    let chain = ""
    if a:level >? 0
        let chain = join(a:keys[0:abs(a:level-1)], ".")
        if !(chain ==? "")
            let chain .= "."
        endif
        "echom "RETURN: " . chain . ", " . a:key
    endif
    return chain . a:key
endfunction

augroup loadVars
    autocmd!
    autocmd BufWritePost,FileWritePost,FileAppendPost * call ReLoadVariables()
augroup END

function ReLoadVariables()
    let g:templates = []
    :call LoadVariables()
endfunction

:call LoadVariables()



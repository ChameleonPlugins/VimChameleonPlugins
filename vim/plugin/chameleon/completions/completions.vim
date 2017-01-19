" Completions


" Message if old version of vim...
if !exists("v:completed_item")
    " ["unix", "win16", "win32", "win64", "win32unix", "win95",
    " "mac", "macunix", "amiga", "os2", "qnx", "beos", "vms"]

    if has("unix") || has("win32unix") || has("mac") || has("maxunix")
              \    || has("qnx") || has("vms")
        echom "Upgrade to vim 7.4.774+ for code completion/Chameleon: sudo add-apt-repository ppa:pkg-vim/vim-daily; sudo apt-get install vim"
    else
        echom "Upgrade to vim 7.4.774+ for code completion/Chameleon"
    endif
"    set statusline=" " . g:msg1
"    set statusline="Upgrade to vim 7.4.774+ for code completion/Chameleon..."
endif


" Settings
" http://vim.wikia.com/wiki/Make_Vim_completion_popup_menu_work_just_like_in_an_IDE
set completeopt=longest,menuone
"inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
"  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
"
"inoremap <expr> <M-,> pumvisible() ? '<C-n>' :
"  \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
" open omni completion menu closing previous if open and opening new menu without changing the text
inoremap <expr> <C-Space> (pumvisible() ? (col('.') > 1 ? '<Esc>i<Right>' : '<Esc>i') : '') .
            \ '<C-x><C-o><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'
" open user completion menu closing previous if open and opening new menu without changing the text
inoremap <expr> <S-Space> (pumvisible() ? (col('.') > 1 ? '<Esc>i<Right>' : '<Esc>i') : '') .
            \ '<C-x><C-u><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'
" Globals
let g:matches = []
let g:templates = get(g:, 'templates', [])
let g:go = 0
" Omnicomplete -------------------- {{{
" http://www.belchak.com/2011/01/31/code-completion-for-python-and-django-in-vim/
filetype plugin on

" set omnifunc=syntaxcomplete#Complete

"autocmd FileType python set omnifunc=pythoncomplete#Complete
"autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
"autocmd FileType css set omnifunc=csscomplete#CompleteCSS

"let g:SuperTabCrMapping = 0
function! SuperCleverTab()
    if strpart(getline('.'), 0, col('.') - 1) =~ '^\s*$'
        return "\<Tab>"
    else
        if &omnifunc != ''
            "return "\<C-X>\<C-O>"
            return "\<C-X>\<C-O>\<C-P>"
        elseif &dictionary != ''
            return "\<C-K>"
        else
            return "\<C-N>"
        endif
    endif
endfunction

:inoremap <Tab> <C-R>=SuperCleverTab()<cr>

" Control-Space
":inoremap <C-Space> <C-R>=SuperCleverTab()<cr>
:inoremap <NUL> <C-R>=SuperCleverTab()<cr>

" Down
":inoremap OB <C-N>
" Up
":inoremap OA <C-P>

filetype plugin on
" }}}



function! Omnifunc (findstart, base)
    "call Debug("Omnifunc Base=" . a:base)
    if a:findstart
        return GetStart()
    else
        return GetCompletions(a:base)
    endif
endfunction

function! GetStart ()
  "call Debug("GetStart col()=" . col('.'))
  return col('.')
  "return 0
endfunction

function! GetCompletions (base)
  let typed = a:base
  if a:base ==? ""
      " current line, with whitespace removed:
      let typed_all = substitute(getline('.'), '^\s*\(.\{}\)\s*$', '\1', '')
      " remove everything up to {{
      let typed_part = substitute(getline('.'), '^.*\({{ .\{}\)$', '\1', '')
  endif
  "call Debug("typed=" . typed)
  let g:matches = []
  "echom "TEMPLATES:"
  let t = 0
  for template in g:templates
      let t = t + 1
"      echom "Template " . string(t)
      for synonym in template.words
"          echom "synonym=" . synonym
          let X = ""
          let typed = typed_all
          if synonym =~? "^".typed_part
              let typed = typed_part
          endif
          " e.g. this is a test ==> this
          " e.g. say X to the user ==> say HELLO to the user
          if synonym =~# "X"
              let synonym = substitute(synonym, "==> .*", "", "")
              echom "synonym = [" . synonym ."]"
              let array = split(synonym, "X")
              let args = []
              let pieces = len(array)
              let item = -1
              let X = substitute(typed, array[0], "", "")
              if len(array) > 1
                " say HI to the (user <-- not yet typed...)
                "Remove beginning: X=HI to the
                let X = substitute(X, array[-1], "", "")
                " synonym = say HI to the to the user
                let synonym = array[0] . X . " " .array[1]
"              else
"                let synonym = array[0] . " " . X
                "X: [HI to the]
                "array[1]="to the user"
                echom "X: [" . X . "]"
                echom "array[" . item . "]: [" . array[item] . "]"
                "input has leading and trailing spaces removed...
                let array[item] = array[item][1:-2]
                echom "array[".item."]': [" . array[item] . "]"
                let X = StripOverlap(X, array[-1])
                echom "X': [" . X . "]"
                let synonym = array[0] . X . array[item]
                echom "synonym': " . synonym
                let arg=1
                for piece in range(pieces-2,1,-1)
                  echom "piece=" . piece
                  let item = -piece
"                let rev = array
"                reverse(rev)
"                for piece in rev
"
"                endif
                  let div=array[piece]
                  echom "div=[" . div . "]"
                  call add(args, SplitArgs(X, div, piece, args))
                  echom "args[" . string(arg-1) . "]=[" . args[arg-1] . "]"
                  let arg=arg+1
                endfor
              endif

          endif
          if synonym =~? "^".typed
          "if synonym =~? "^".typed
              "call Debug("synonym (".synonym.") =~? ^typed (^".typed.")")
              let synonym_part = synonym[len(typed):]
              "call Debug("synonym_part=[" . synonym_part . "]")
              let replace = template.replace
              if replace =~? "X1"
                  let replace = substitute(replace, "X1", X, "g")
              endif
              call add( g:matches, {'word': synonym_part,
                          \'replace': replace,
                          \'type': template.type,
                          \'file' : template.file} )
              "echom "add file: " . template.file
"          else
"              if synonym =~? "^help with chameleon"
"                  let g:help_template = template
"                  "echom "help synonym=>" . synonym
"              endif
          endif
      endfor
  endfor
  "echom "typed_all=" . typed_all
  "echom "typed_part=" . typed_part
  "echom "len(g:matches)=" . string(len(g:matches))
"  if len(g:matches) ==? 1
"      call add( g:matches, {'synonym': g:help_template['synonyms'][0],
"\       'replace': g:help_template['replace']} )
"  endif
  return {'words': g:matches, 'refresh': 'always'}
endfunction

" e.g.:
" div = " to "
" X = "HI to test.txt"
function! SplitArgs(X, div, piece, args)
    "find div in X
    let location = match(a:X, a:div)
    echom "X=[" . a:X . "]"
    echom a:div . " located at location=" . location
    "get remaining
    let remainder = a:X[location+len(a:div):]
    echom "remaining = remainder=" . remainder
    "store in args
"    let a:args[a:piece] = remainder
"    call add(a:args, remainder)
"    echom 'args[0]=' . a:args[0]
    return remainder
endfunction

"say X to X file:
"typed: HI to "test.txt" file
"synonym:                   file
"synonym:  to the user
"let X = StripOverlap(X, array[1])



" say X to the user:
"typed: HI to the
"synonym:       to the user
"synonym:  to the user
"let X = StripOverlap(X, array[1])
function! StripOverlap(typed, synonym)
    echom "StripOverlap(".a:typed.",".a:synonym.")"
    let remaining = a:typed
    let max_overlap_length = min([len(a:typed), len(a:synonym)])
    let right = a:synonym[:-max_overlap_length+3]
    "for length in range(1, max_overlap_length)
    for length in range(max_overlap_length, 1, -1)
        let left = a:typed[-length:]
        "let right = a:synonym[:length]
        let right = a:synonym[:-(2*max_overlap_length)+length+3]
        echom "[" . left . "] ==? [" . right . "]"
        if left ==? right
            let rval = a:typed[:len(a:typed)-length-1]
            echom "rval=" . rval
            return rval
        endif
    endfor
    return a:typed
endfunction

set omnifunc=Omnifunc
"set completefunc=Omnifunc

augroup completions
    autocmd!
    autocmd CompleteDone * call OnCompleteDone()
augroup END

function! OnCompleteDone()
"    echom "go=" . g:go
    if len(v:completed_item) > 0
        for matched in g:matches
            "echom "completed_item.word:" . v:completed_item.word
            "echom "matched.word:" . matched.word
            if matched.word ==? v:completed_item.word
                "echom "matched.word:" . matched.word
                let type = matched.type
                let replacement = matched.replace
                let rows=string(strlen(substitute(replacement,
\                   "[^\n]", "", "g")) + 1)
                :set paste
                if type ==? "variable"
                    "echom "VARIABLE"
                    " Remove ' = .* '
                    :execute "normal! ?=\<cr>d$xA "
                    :execute "normal! \<esc>$xA"
                    :call GoRight()
                    "echom "line=" . getline('.')
                    "echom "replacement=" . replacement
                    let search = substitute(replacement, "{{ ", "", "")
                    let search = substitute(search, " }}", "", "")
                    if g:go
                        let file = substitute(matched.word, ".*[", "", "")
                        let file = substitute(file, "]", "", "")
                        let path = expand('%:p:h')
                        "echom "file=" . file
                        "echom "path=" . path
                        let hs = ""
                        let dir = " "
                        while dir != '' && dir != 'roles'
                            let dir = expand('%:p:h:h' . hs . ':t')
                            let hs = hs . ':h'
                        endwhile
                        let path = expand('%:p:h' . hs)
                        "echom "path=" . path
                        " find .../roles/
                        if dir ==? 'roles'
                            if FileExists(path)
                                if FileExists(path."/".file."/vars/main.yml")
                                    :call OpenFile(path . "/" . file . "/vars/main.yml", search)
                                    :execute "normal! \<esc>$"
                                elseif FileExists(path."/".file."/defaults/main.yml")
                                    :call OpenFile(path . "/" . file . "/defaults/main.yml", search)
                                    :execute "normal! \<esc>$"
                                endif
                            endif
                        endif
                        let g:go = 0
                    endif
                elseif type ==? "snippet" || type ==? "template"
                    ":echom "rows=" . rows
                    ":echom "replacement=[" . replacement . "]"
                    :execute "normal! i\<cr>" . replacement . "\<esc>" . rows .
\                    "kdd" . rows . "j\<cr>\<esc>kk"
                elseif type ==? "script"
                    ":echom "type=script; source " . matched.file
                    "Remove typed text...
                    :execute "normal! ddO"
"\                    "kdd" . rows . "i\<cr>\<esc>j"
                    "source in script...
                    :execute ":source " . matched.file
                    :call GoRight()
                endif
                :set nopaste
                return
            endif
        endfor
    endif
endfunction

" During code completions, > will jump to file, for variables...
":inoremap <Down> <C-R>=pumvisible() ? "\<lt>C-N>\<lt>ESC>:sp ~/.vimrc\<lt>CR>" : "\<lt>Down>"<CR>
":inoremap . <C-R>=pumvisible() ? "\<lt>C-N>\<lt>ESC>:sp ~/.vimrc\<lt>CR>" : "."<CR>
":inoremap > <C-R>=pumvisible() ? "\<lt>C-N>\<lt>ESC>:sp ~/.vimrc\<lt>CR>" : ">"<CR>
":inoremap <Right> <C-R>=pumvisible() ? "\<lt>C-N>\<lt>ESC>:sp ~/.vimrc\<lt>CR>" : "\<lt>Right>"<CR>
":inoremap <Right> <C-R>=pumvisible() ? "\<lt>C-N>\<lt>ESC>:sp ".v:completed_item."\<lt>CR>" : "\<lt>Right>"<CR>

:inoremap <Right> <C-R>=SetOpenFile()<CR>
function! SetOpenFile()
    if pumvisible()
        let g:go = 1
        return "\<CR>"
    endif
    return "\<Right>"
endfunction

function! FileExists(path)
    return !empty(glob(a:path))
endfunction

function! OpenFile(path, search)
    "echom ":execute normal! :sp " . a:path . "<cr>"
    :execute "normal! :sp " . a:path . "\<cr>"
    "echom "SPLIT: " . a:search
    let array = split(a:search, '\.')
    echom "array[0]=" . array[0]
    let n = 0
    for s in array
        while n >=? 0
            :call SearchFor(s)
            let n = n - 1
        endwhile
        if s =~? "\["
            let n = substitute(s, ".*\[", "", "")
            let n = substitute(n, "\]", "", "")
            let s = substitute(s, "\[.*", "", "")
        endif
    endfor
endfunction

function! SearchFor(search)
    "echom "SEARCH: /" . a:search . "/"
    :execute "normal! \<esc>/" . a:search . "\<cr>\<esc>$n"
    :set hlsearch
endfunction

function! GoRight()
    " Workaround to advance cursor to the right
    let a:cursor_position = getpos(".")
    :call cursor(a:cursor_position[1], a:cursor_position[2]+1)
endfunction



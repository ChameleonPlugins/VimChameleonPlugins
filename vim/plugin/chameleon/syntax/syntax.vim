" " set t_Co=256
:syntax on

" Warning at 77 characters...
" ##############################################################################
:au BufWinEnter * let w:m1=matchadd('Search', '\%<81v.\%>77v', -1)
" [HLMANSIBLE0003] WARNING - Line length > 80 chars
" ##################################################################################
:au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)

"Show trailing whitespace:     
:highlight TrailingWhitespace ctermbg=red guibg=red
:au BufWinEnter * let w:m3=matchadd('TrailingWhitespace', '\s\+$')

" 	Show spaces before a tab:
:highlight SpacesBeforeTab ctermbg=red guibg=red
:au BufWinEnter * let w:m4=matchadd('SpacesBeforeTab', ' \+\ze\t')

" Show	tabs that are not at the start of a line:
:highlight TabsNotAtStartOfLine ctermbg=red guibg=red
:au BufWinEnter * let w:m5=matchadd('TabsNotAtStartOfLine', '[^\t]\zs\t\+')

   " Show odd number of spaces indentation
:highlight OddIndentation ctermbg=red guibg=red
:au BufWinEnter * let w:m6=matchadd('OddIndentation', '\v^ (  )*[^ ]')

" [HLM-ANSIBLE0015] sudo is deprecated - use "become"
" Depricated: sudo: yes
:highlight OddIndentation ctermbg=red guibg=red
:au BufWinEnter * let w:m7=matchadd('OddIndentation', 'sudo: yes')

" [HLM-ANSIBLE0008] Missing spaces around variable name
" Missing whitespace around variable names on left {{variable }} 
:highlight SpacesAroundVariables ctermbg=red guibg=red
:au BufWinEnter * let w:m8=matchadd('SpacesAroundVariables', '\v\{\{[^ ]')

" [HLM-ANSIBLE0008] Missing spaces around variable name
" Missing whitespace around variable names on right {{ variable}} 
:highlight SpacesAroundVariables ctermbg=red guibg=red
:au BufWinEnter * let w:m9=matchadd('SpacesAroundVariables', '\v[^ ]\}\}')

" [HLMANSIBLE0006] Action name should match $role | $task | description
let role=expand('%:p:h:h:t')
let task=expand('%:p:t:r')
let role_task=role . ' | ' . task
let actionNamePattern='^- name: \(' . role . '\ |\ ' . task . '\ |\ \)\@!'
:highlight ActionName ctermbg=red guibg=red
:au BufWinEnter * let w:m10=matchadd('ActionName', actionNamePattern)

" [HLMANSIBLE0010] Use key: value syntax
":highlight KeyValue ctermbg=lightblue guibg=lightblue
":au BufWinEnter * let w:m11=matchadd('KeyValue', '\v^[- ].*\:.*\=')

" [HLMANSIBLE0009] Registered variables must end in _result unless prefixed
" with hlm_notify
"highlight RegisteredVariables ctermbg=red guibg=red
"let registeredVariablePattern='\v\ \ register\:\ .*\(_result\)\@!'
":au BufWinEnter * let w:m5=matchadd('RegisteredVariables',
"  \ registeredVariablePattern)


" [HLMANSIBLE0009] Registered variables must end in _result unless prefixed
" with hlm_notify
:highlight RegisteredVariables ctermbg=red guibg=red
let registeredVariablePattern=
  \ '  register\: \(hlm_notify.*\)\@!\&\(.*_result.*\)\@!'
:au BufWinEnter * let w:m12=matchadd(
  \ 'RegisteredVariables', registeredVariablePattern)


" Missing quotes
:highlight MissingQuotes ctermbg=red guibg=red
"let MissingQuotesPattern='\v^\ *[a-z]*\:\ .*[^"]\{\{'
let MissingQuotesPattern='[^"]{{'
:au BufWinEnter * let w:m13=matchadd('MissingQuotes', MissingQuotesPattern)

" [ANSIBLE0007] rm used in place of argument state=absent to file module
:highlight RmUsedInsteadOfAbsent ctermbg=red guibg=red
let rmPattern='  shell: "rm'
:au BufWinEnter * let w:m11=matchadd('RmUsedInsteadOfAbsent', rmPattern)

" Shortcuts ----------------------- {{{

" Shortcuts to convet key=value to key: value
" [HLMANSIBLE0010] Use key: value syntax
:nnoremap <leader>= /=<cr>
:nnoremap <leader>0 bhxi<cr><esc>0dwi    <esc>wwr:li <esc>/=<cr>

" Shortcut to split long line with >
" [HLMANSIBLE0003] WARNING - Line length > 80 chars
:nnoremap <leader>. 0/:<cr>lli><cr><esc>0dwi    <esc>40lw:noh<cr>
:nnoremap <leader><cr> hi<cr><esc>0dwi    <esc>40lW:noh<cr>

" Shortcut to add space around variable name
" [HLM-ANSIBLE0008] Missing spaces around variable name
:nnoremap <leader>[ /{{[^ ]<cr>wi <esc>/[^ ]}}<cr>li <esc>:noh<cr>
:nnoremap <leader>] /{{[^ ]<cr>wi <esc>/[^ ]}}<cr>li <esc>:noh<cr>

" Shortcut to fix name format
" [HLMANSIBLE0006] Action name should match $role | $task | description
:nnoremap <leader>- :execute "normal! 0www3cW" . role_task <cr>

" Shortcut to quote variables
:nnoremap <leader>' /: {{<cr>wi"<esc>$a"<esc>:noh<cr>

" }}}

" TBD:
" [ANSIBLE0003] Mismatched { and }
" [ANSIBLE0007] rm used in place of argument state=absent to file module





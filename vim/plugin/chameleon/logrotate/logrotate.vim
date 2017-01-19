" Logrotate wiki:
"http://wiki.hpcloud.net/
" display/core/Logrotate+and+Centralized+logging+for+Service+Teams

" Formula:
" SUM of weight*files !> 100%
"
" Old Formula:
" SUM of (maxsize + (maxsize * rotate * 0.2)) !> 2.5 G

" Initialization
let g:MAX_SIZE_GB = -1
let g:MAX_SIZE = -1
let g:MAX_WEIGHT = 100 " %
let g:service_files_total_size = -1
let g:service_files_total_weight = -1
let g:service_name = ""
let g:footer_text = ""
let g:total_files = 0

" Functions
function! SetFooter()
    return g:footer_text
    "return SetFooterText()
endfunction

function! SetFooterText()
    " Find other files in this section if not already done...
    let last_service_name = g:service_name
    let g:service_name = GetServiceName()
    if last_service_name !=? g:service_name
        let g:service_files_total_size = -1
        let g:service_files_total_weight = -1
    endif

    if g:service_files_total_size <? 0
        let g:service_files_total_size = GetServiceFilesTotalSize()
    endif
    if g:service_files_total_weight <? 0
        let g:service_files_total_weight = GetServiceFilesTotalWeight()
    endif

    let current_file_total_size = GetSizeForCurrentFile()
    let current_file_total_weight = GetWeightForCurrentFile()
    let total_size = g:service_files_total_size + current_file_total_size
    let total_weight = g:service_files_total_weight + current_file_total_weight
    if total_weight > 0
        let text = printf("Current file: %.0f%%%%", current_file_total_weight)
        let text = text . printf(" in %d file entries", g:total_files)
        let text = text . printf(" + Others: %.0f%%%%", g:service_files_total_weight)
        let text = text . printf(" = TOTAL: %.0f%%%%", total_weight)
        if total_weight >? g:MAX_WEIGHT
    "         hi statusline guibg=red
            hi StatusLine term=reverse ctermfg=7 ctermbg=1 gui=undercurl guisp=Red
            let text = text . printf(" OVER BY %.0f%%%%!!", total_weight - g:MAX_WEIGHT)
        else
    "         hi statusline guibg=green
            hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
            let text = text . printf(" under by %.0f%%%%", g:MAX_WEIGHT - total_weight)
        endif
    else
        let text = printf("Current file = %.0fM", current_file_total_size)
        let text = text . printf(" Others = %.0fM", g:service_files_total_size)
        let text = text . printf(" TOTAL = %.0fM", total_size)
        if total_size >? g:MAX_SIZE
    "         hi statusline guibg=red
            hi StatusLine term=reverse ctermfg=7 ctermbg=1 gui=undercurl guisp=Red
            let text = text . printf(" OVER MAX OF %0.fM by ", g:MAX_SIZE)
            let text = text . printf("%.0fM!!", total_size - g:MAX_SIZE)
        else
    "         hi statusline guibg=green
            hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
            let text = text . printf(" under max of %.0fM by ", g:MAX_SIZE)
            let text = text . printf("%.0fM", g:MAX_SIZE - total_size)
        endif
    endif
    let text = text . " (:messages for more info)"

    let g:footer_text = text
    :set statusline=%!SetFooter()
    return text
endfunction


function! GetServiceFilesTotalSize()
    let total_file_size = 0
    let g:service_name = GetServiceName()
    let files = filter(split(globpath(getcwd(), '*.yml'), '\n'),
        \ !'isdirectory(v:val)')
    let total_files_size = 0
    for file in files
        let short_filename = fnamemodify(file, ":t")
        if short_filename !=? bufname("%")
            let file_size = GetSizeForFile(file)
            let total_file_size = total_file_size + file_size
            if file_size >? 0
                echom printf("%.0fM for %s in %d file entries",
                            \ file_size, short_filename, g:total_files)
            endif
        endif
    endfor
    echom printf("%.0fM  <== Total Size from other files", total_file_size)
    return total_file_size
endfunction

function! GetServiceFilesTotalWeight()
    let total_file_weight = 0
    let g:service_name = GetServiceName()
    let files = filter(split(globpath(getcwd(), '*.yml'), '\n'),
        \ !'isdirectory(v:val)')
    let total_files_weight = 0
    for file in files
        let short_filename = fnamemodify(file, ":t")
        if short_filename !=? bufname("%")
            let file_weight = GetWeightForFile(file)
            let total_file_weight = total_file_weight + file_weight
            if file_weight >? 0
                echom printf("%.0f%% for %s in %d file entries",
                            \ file_weight, short_filename, g:total_files)
            endif
        endif
    endfor
    echom printf("%.0f%%%  <== Total Weight from other files", total_file_weight)
    return total_file_weight
endfunction

function! GetServiceName()
    let current = 0
    let service = ""
    while current < line('$') && !service
        let current = current + 1
        let line = getline(current)
        if line =~? '  service: .*'
	    " Drop the first 11 characters, leaving just the value
            let service = strpart(line, 11)
        endif
    endwhile
    return service
endfunction

function! GetSizeForFile(file)
    let lines = readfile(a:file)
    return GetSizeForLines(lines)
endfunction

function! GetWeightForFile(file)
    let lines = readfile(a:file)
    return GetWeightForLines(lines)
endfunction

function! GetSizeForCurrentFile()
    let lines = getline(1, line('$'))
    return GetSizeForLines(lines)
endfunction

function! GetWeightForCurrentFile()
    let lines = getline(1, line('$'))
    return GetWeightForLines(lines)
endfunction

function! GetSizeForLines(lines)
    let sections = 0
    let total_files = 0
    let total_size = 0
    let total_weight = 0

    let files = 0
    let maxsize = 0
    let weight = 0
    let rotate = 0

    let in_files = 0

    let current = 0
    while current <? len(a:lines)-1
        let current = current + 1
        let line = a:lines[current]
        if line =~? '^    - .*' || current ==? len(a:lines)-1
            let sections = sections + 1

	    " Add up values from previous section...
	    let total_size = total_size + files * (maxsize + (0.2 * maxsize * rotate))
	    let total_weight = total_weight + files * (maxsize + (0.2 * maxsize * rotate))

	    " Zero out values for this new section...
            let files = 0
	    let maxsize = 0
	    let weight = 0
	    let rotate = 0
        elseif line =~? '  service: .*'
	    " Drop the first 11 characters, leaving just the value
            let service = strpart(line, 11)
            if service !=? g:service_name
                return 0
            endif
	elseif line =~? 'files:$'
            let in_files = 1
	elseif line =~? '^      - .*' && in_files
            let files = files + 1
            let total_files = total_files + 1
	elseif line !~? '^      - .*' && in_files
            let in_files = 0
	elseif line =~? '^      - rotate.*'
	    " Drop the first 15 characters, leaving just the value
            let rotate = strpart(line, 15)
	elseif line =~? '^      - weight.*'
	    " Drop the first 14 characters, leaving just the value
            " Remove the last character (%)
            let weight = strpart(line, 15)[:-2]
	elseif line =~? '^      - maxsize.*'
	    " Drop the first 15 characters, leaving just the value
            " Remove the last character
            let maxsize = strpart(line, 16)[:-2]
            let multiplier = line[-1:]
            "call Debug("Multiplier=" . multiplier)
            if multiplier ==? "K"
                let maxsize = maxsize * 0.001
            elseif multiplier ==? "G"
                let maxsize = maxsize * 1024
            endif
        endif
    endwhile
    return total_size
endfunction

function! GetWeightForLines(lines)
    let sections = 0
    let g:total_files = 0
    let total_weight = 0

    let files = 0
    let weight = 0
    let rotate = 0

    let in_files = 0

    let current = 0
    while current <? len(a:lines)-1
        let current = current + 1
        let line = a:lines[current]
        if line =~? '^    - .*' || current ==? len(a:lines)-1
            let sections = sections + 1

	    " Add up values from previous section...
	    let total_weight = total_weight + files * weight

	    " Zero out values for this new section...
            let files = 0
	    let weight = 0
	    let rotate = 0
        elseif line =~? '  service: .*'
	    " Drop the first 11 characters, leaving just the value
            let service = strpart(line, 11)
            if service !=? g:service_name
                return 0
            endif
	elseif line =~? 'files:$'
            let in_files = 1
	elseif line =~? '^      - .*' && in_files
            let files = files + 1
            let g:total_files = g:total_files + 1
	elseif line !~? '^      - .*' && in_files
            let in_files = 0
	elseif line =~? '^      - rotate.*'
	    " Drop the first 15 characters, leaving just the value
            let rotate = strpart(line, 15)
	elseif line =~? '^      - weight.*'
	    " Drop the first 14 characters, leaving just the value
            " Remove the last character (%)
            let weight = strpart(line, 15)[:-2]
	elseif line =~? '^      - maxsize.*'
	    " Drop the first 15 characters, leaving just the value
            " Remove the last character
            let maxsize = strpart(line, 16)[:-2]
            let multiplier = line[-1:]
            "call Debug("Multiplier=" . multiplier)
            if multiplier ==? "K"
                let maxsize = maxsize * 0.001
            elseif multiplier ==? "G"
                let maxsize = maxsize * 1024
            endif
        endif
    endwhile
    return total_weight
endfunction

let dir=expand('%:p:h:t')
let parent_dir=expand('%:p:h:h:t')
if parent_dir ==? "logging-common" && dir ==? "vars"
    " first, enable status line always
    set laststatus=2

    " Get this from service_log_directory_size_quota: 2.5 #(GB)
    " in ../defaults/main.yml and multiply by 1024
    let service_log_directory_size_quota =
    \system("cat ../defaults/main.yml |
    \grep service_log_directory_size_quota | awk '{print $2}'")

    let service_log_directory_size_quota = service_log_directory_size_quota[:-2]
    let g:MAX_SIZE_GB = str2float(service_log_directory_size_quota)
    "call Debug("g:MAX_GB = " . string(g:MAX_SIZE_GB))

    if g:MAX_SIZE_GB <= 0
        let g:MAX_SIZE_GB = 2.5 "Default value...
    endif

    let g:MAX_SIZE = 1024.0 * g:MAX_SIZE_GB
    "call Debug("g:MAX_SIZE = " . string(g:MAX_SIZE))

    :set statusline=%!SetFooter()
    augroup logrotateGroup
        autocmd!
        autocmd VimEnter,TextChanged,InsertLeave *.yaml,*.yml
                    \ :call SetFooterText()
    augroup END

endif


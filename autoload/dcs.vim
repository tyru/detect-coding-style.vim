" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



let s:filetype_vs_range_pattern = {
\   'vim' : ['^\s*\<fu\%[nction]\>\(!\)\@<!', '^\s*\<endf\%[unction]\>'],
\}



function! dcs#load() "{{{
    " dummy function to load this script.
endfunction "}}}


function! dcs#detect(bufnr) "{{{
    let NONE = 0
    let ft = getbufvar(a:bufnr, '&filetype')
    if !dcs#supported_filetype(ft)
        return NONE
    endif

    let whole_lines = getbufline(a:bufnr, 1, '$')
    let [start_pattern, end_pattern] = s:filetype_vs_range_pattern[ft]

    let start = match(whole_lines, start_pattern)
    if start == -1
        return NONE
    endif
    let end = match(whole_lines, end_pattern, start + 1)
    if end == -1
        return NONE
    endif

    return dcs#detect_from_lines(whole_lines[start : end])
endfunction "}}}

function! dcs#supported_filetype(filetype) "{{{
    return has_key(s:filetype_vs_range_pattern, a:filetype)
endfunction "}}}


function! dcs#detect_from_lines(lines) "{{{
    if s:is_maybe_gnu(a:lines)
        execute g:dcs_coding_styles.gnu
    elseif s:is_maybe_bsd(a:lines)
        execute g:dcs_coding_styles.bsd
    elseif s:is_maybe_linux(a:lines)
        execute g:dcs_coding_styles.linux
    endif
endfunction "}}}

function! s:is_maybe_gnu(lines) "{{{
    " Tabs and whitespaces are mixed.
    let sp = 0
    let tab = 0
    for l in a:lines
        if l =~# '^ \+'
            let sp = 1
        elseif l =~# '^\t\+'
            let tab = 1
        endif
        if sp && tab
            return 1
        endif
    endfor
    if sp && tab
        return 1
    endif
    return 0
endfunction "}}}

" TODO
function! s:is_maybe_bsd(lines) "{{{
    return 0
endfunction "}}}

" TODO
function! s:is_maybe_linux(lines) "{{{
    return 0
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

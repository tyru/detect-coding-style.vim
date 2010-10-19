" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


function! dcs#styles#gnu#define() "{{{
    let o = {}
    let o.excmd =
    \   'setlocal expandtab tabstop=8 '
    \   . 'shiftwidth=2 softtabstop=2 preserveindent'
    function! o.detect_from_lines(lines)
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
    endfunction

    return o
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

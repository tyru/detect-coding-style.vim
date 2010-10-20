" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


function! dcs#detectors#linux#define_name() "{{{
    return 'Linux'
endfunction "}}}

function! dcs#detectors#linux#define() "{{{
    let o = {}
    function! o.detect_from_lines(lines)
        return 0    " TODO
    endfunction

    return o
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

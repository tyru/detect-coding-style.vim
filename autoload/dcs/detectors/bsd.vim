" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


function! dcs#detectors#bsd#style_name() "{{{
    return 'BSD'
endfunction "}}}

function! dcs#detectors#bsd#define() "{{{
    let o = {}
    let o.hook_excmd =
    \   'setlocal expandtab tabstop=8 '
    \   . 'shiftwidth=4 softtabstop& preserveindent'
    function! o.detect_from_lines(lines)
        return 0    " TODO
    endfunction

    return o
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

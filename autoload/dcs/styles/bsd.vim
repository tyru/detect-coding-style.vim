" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


function! dcs#styles#bsd#define_name() "{{{
    return 'BSD'
endfunction "}}}

function! dcs#styles#bsd#define() "{{{
    let o = {}
    let o.hook_excmd =
    \   'setlocal expandtab tabstop=8 '
    \   . 'shiftwidth=4 softtabstop& preserveindent'

    return o
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

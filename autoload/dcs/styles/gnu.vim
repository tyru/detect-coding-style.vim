" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


function! dcs#styles#gnu#define_name() "{{{
    return 'GNU'
endfunction "}}}

function! dcs#styles#gnu#define() "{{{
    let o = {}
    let o.hook_excmd =
    \   'setlocal expandtab tabstop=8 '
    \   . 'shiftwidth=2 softtabstop=2 preserveindent'

    return o
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

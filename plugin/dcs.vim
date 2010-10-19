" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_dcs') && g:loaded_dcs
    finish
endif
let g:loaded_dcs = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


if !exists('g:dcs_coding_styles')
    let g:dcs_coding_styles = {
    \   'gnu': 'set expandtab tabstop=8 '
    \           . 'shiftwidth=2 softtabstop=2 '
    \           . 'preserveindent',
    \   'bsd': 'set expandtab tabstop=8 '
    \           . 'shiftwidth=4 softtabstop& '
    \           . 'preserveindent',
    \   'linux': 'set expandtab tabstop=8 '
    \           . 'shiftwidth=8 softtabstop& '
    \           . 'preserveindent',
    \}
endif
if !exists('g:dcs_no_default_autocmd')
    let g:dcs_no_default_autocmd = 0
endif


command! -bar DetectCodingStyle call dcs#detect(expand('%'))

if !g:dcs_no_default_autocmd
    augroup detect-coding-style
        autocmd!
        autocmd BufEnter * DetectCodingStyle
    augroup END
endif


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

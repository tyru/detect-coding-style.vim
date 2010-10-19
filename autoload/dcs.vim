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


function! dcs#detect_from_bufnr(bufnr) "{{{
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

    call s:register_installed_styles()
    return dcs#detect_from_lines(whole_lines[start : end])
endfunction "}}}
function! s:register_installed_styles() "{{{
    if exists('s:done_register_installed_styles')
        return
    endif

    for file in split(globpath(&rtp, 'autoload/dcs/styles/*.vim'), '\n')
        let name = fnamemodify(file, ':t:r')
        let style = dcs#styles#{name}#define()
        if !s:DetectorManager.register(name, style)
            echohl WarningMsg
            echomsg "warning: dcs: plugin '" . name
            \   . "' returned invalid object."
            echohl None
        endif
    endfor

    let s:done_register_installed_styles = 1
endfunction "}}}
function! dcs#detect_from_lines(...) "{{{
    call s:DetectorManager.delegate('detect_from_lines', a:000)
endfunction "}}}
function! dcs#supported_filetype(filetype) "{{{
    return has_key(s:filetype_vs_range_pattern, a:filetype)
endfunction "}}}


" s:DetectorManager {{{
let s:DetectorManager = {'__detectors': {}}

function! s:DetectorManager.register(name, detector) "{{{
    if s:check_style_dict(a:detector)
        let self.__detectors[a:name] = a:detector
        return 1
    endif
    return 0
endfunction "}}}
function! s:check_style_dict(dict) "{{{
    return
    \   has_key(a:dict, 'detect_from_lines')
    \   && has_key(a:dict, 'excmd')
endfunction "}}}
function! s:DetectorManager.delegate(method_name, args) "{{{
    for name in sort(keys(self.__detectors))
        let style = self.__detectors[name]

        if call(style[a:method_name], a:args, style)
            execute style.excmd
            let b:dcs_current_style = name
            return
        endif
    endfor
endfunction "}}}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

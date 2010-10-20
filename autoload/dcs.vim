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

    return dcs#detect_from_lines(whole_lines[start : end])
endfunction "}}}
function! dcs#detect_from_lines(...) "{{{
    call s:DetectorManager.delegate_each('detect_from_lines', a:000)
endfunction "}}}
function! dcs#supported_filetype(filetype) "{{{
    return has_key(s:filetype_vs_range_pattern, a:filetype)
endfunction "}}}
function! dcs#set_detector_attr(...) "{{{
    return call(s:DetectorManager.set_detector_attr, a:000, s:DetectorManager)
endfunction "}}}


" s:DetectorManager {{{
let s:DetectorManager = {'__detectors': {}}

function! s:DetectorManager.register_detector(name, detector) "{{{
    if self._check_detector_dict(a:detector)
    \   && !has_key(self.__detectors, a:name)
        let self.__detectors[a:name] = a:detector
        return 1
    endif
    return 0
endfunction "}}}
function! s:DetectorManager._check_detector_dict(dict) "{{{
    return
    \   has_key(a:dict, 'detect_from_lines')
    \   && has_key(a:dict, 'hook_excmd')
endfunction "}}}
function! s:DetectorManager.get_detector(name, ...) "{{{
    call self._register_installed_detectors()
    if a:0
        return get(self.__detectors, a:name, a:1)
    else
        return self.__detectors[a:name]
    endif
endfunction "}}}
function! s:DetectorManager.get_all_detector_names() "{{{
    call self._register_installed_detectors()
    return sort(keys(self.__detectors))
endfunction "}}}
function! s:DetectorManager._register_installed_detectors() "{{{
    if has_key(self, '__done_register_installed_detectors')
        return
    endif

    " autoload/dcs/detectors/*.vim settings is only about tab.
    " See the followings for the details:
    "   http://www.jukie.net/bart/blog/vim-and-linux-coding-style
    "   http://yuanjie-huang.blogspot.com/2009/03/vim-in-gnu-coding-style.html
    "   http://en.wikipedia.org/wiki/Indent_style
    " But wikipedia is dubious, I think :(

    for file in split(globpath(&rtp, 'autoload/dcs/detectors/*.vim'), '\n')
        let name = fnamemodify(file, ':t:r')
        let detector = dcs#detectors#{name}#define()
        if exists('*dcs#detectors#' . name . '#style_name')
            let name = dcs#detectors#{name}#style_name()
        endif
        if !s:DetectorManager.register_detector(name, detector)
            echohl WarningMsg
            echomsg "warning: dcs: plugin '" . name
            \   . "' returned invalid object."
            echohl None
        endif
    endfor

    " This code must be run only once.
    autocmd User dcs-initilized-detectors :    " dummy
    doautocmd User dcs-initilized-detectors

    let self.__done_register_installed_detectors = 1
endfunction "}}}
function! s:DetectorManager.delegate_each(method_name, args) "{{{
    for name in self.get_all_detector_names()
        let detector = self.get_detector(name)

        if call(detector[a:method_name], a:args, detector)
            execute detector.hook_excmd
            let b:dcs_current_detector = name
            return
        endif
    endfor
endfunction "}}}
function! s:DetectorManager.run_hook_excmd(name) "{{{
    execute self.get_detector(a:name).hook_excmd
endfunction "}}}
function! s:DetectorManager.set_detector_attr(name, attr, Value) "{{{
    let detector = self.get_detector(a:name)
    if has_key(detector, a:attr)
        let detector[a:attr] = a:Value
    endif
endfunction "}}}

" }}}


" :CodingStyle
function! dcs#_cmd_coding_style(choice) "{{{
    call s:DetectorManager.run_hook_excmd(a:choice)
endfunction "}}}
function! dcs#_cmd_complete_coding_style(...) "{{{
    return s:DetectorManager.get_all_detector_names()
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

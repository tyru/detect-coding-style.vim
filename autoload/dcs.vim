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
    \   && s:StyleManager.has_style(a:name)
        let self.__detectors[a:name] = a:detector
        return 1
    endif
    return 0
endfunction "}}}
function! s:DetectorManager._check_detector_dict(dict) "{{{
    return
    \   has_key(a:dict, 'detect_from_lines')
    \   && type(a:dict.detect_from_lines) == type(function('tr'))
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

    call s:StyleManager._register_installed_styles()

    " autoload/dcs/detectors/*.vim settings is only about tab.
    " See the followings for the details:
    "   http://www.jukie.net/bart/blog/vim-and-linux-coding-style
    "   http://yuanjie-huang.blogspot.com/2009/03/vim-in-gnu-coding-style.html
    "   http://en.wikipedia.org/wiki/Indent_style
    " But wikipedia is dubious, I think :(

    for file in split(globpath(&rtp, 'autoload/dcs/detectors/*.vim'), '\n')
        let name = fnamemodify(file, ':t:r')
        let detector = dcs#detectors#{name}#define()
        if exists('*dcs#detectors#' . name . '#define_name')
            let name = dcs#detectors#{name}#define_name()
        endif
        if !self.register_detector(name, detector)
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
            let style = s:StyleManager.get_style(name)
            execute style.hook_excmd
            let b:dcs_current_detector = name
            return
        endif
    endfor
endfunction "}}}
function! s:DetectorManager.set_detector_attr(name, attr, Value) "{{{
    let detector = self.get_detector(a:name)
    if has_key(detector, a:attr)
        let detector[a:attr] = a:Value
    endif
endfunction "}}}

" }}}

" s:StyleManager {{{
let s:StyleManager = {'__styles': {}}

function! s:StyleManager.register_style(name, style) "{{{
    if self._check_style_dict(a:style)
    \   && !has_key(self.__styles, a:name)
        let self.__styles[a:name] = a:style
        return 1
    endif
    return 0
endfunction "}}}
function! s:StyleManager._check_style_dict(dict) "{{{
    return
    \   has_key(a:dict, 'hook_excmd')
    \   && type(a:dict.hook_excmd) == type("")
endfunction "}}}
function! s:StyleManager.has_style(name) "{{{
    call self._register_installed_styles()
    return has_key(self.__styles, a:name)
endfunction "}}}
function! s:StyleManager.get_style(name) "{{{
    call self._register_installed_styles()
    return self.__styles[a:name]
endfunction "}}}
function! s:StyleManager.get_all_style_names() "{{{
    call self._register_installed_styles()
    return sort(keys(self.__styles))
endfunction "}}}
function! s:StyleManager._register_installed_styles() "{{{
    if has_key(self, '__done_register_installed_styles')
        return
    endif

    " autoload/dcs/styles/*.vim settings is only about tab.
    " See the followings for the details:
    "   http://www.jukie.net/bart/blog/vim-and-linux-coding-style
    "   http://yuanjie-huang.blogspot.com/2009/03/vim-in-gnu-coding-style.html
    "   http://en.wikipedia.org/wiki/Indent_style
    " But wikipedia is dubious, I think :(

    for file in split(globpath(&rtp, 'autoload/dcs/styles/*.vim'), '\n')
        let name = fnamemodify(file, ':t:r')
        let style = dcs#styles#{name}#define()
        if exists('*dcs#styles#' . name . '#define_name')
            let name = dcs#styles#{name}#define_name()
        endif
        if !self.register_style(name, style)
            echohl WarningMsg
            echomsg "warning: dcs: plugin '" . name
            \   . "' returned invalid object."
            echohl None
        endif
    endfor

    " This code must be run only once.
    autocmd User dcs-initilized-styles :    " dummy
    doautocmd User dcs-initilized-styles

    let self.__done_register_installed_styles = 1
endfunction "}}}

" }}}


" :CodingStyle
function! dcs#_cmd_coding_style(choice) "{{{
    if s:StyleManager.has_style(a:choice)
        execute s:StyleManager.get_style(a:choice).hook_excmd
    else
        echohl ErrorMsg
        echomsg "error: dcs: No such style '" . style . "'."
        echohl None
    endif
endfunction "}}}
function! dcs#_cmd_complete_coding_style(...) "{{{
    return s:StyleManager.get_all_style_names()
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

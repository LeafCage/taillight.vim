if expand('<sfile>:p')!=#expand('%:p') && exists('g:loaded_taillight')| finish| endif| let g:loaded_taillight = 1
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
let g:taillight_regulars = get(g:, 'taillight_regulars', ['{', '}'])
command! -nargs=?   TailLight    call s:change_strs(<q-args>)

aug TailLight
  autocmd!
  autocmd ColorScheme *   call s:define_hl()
  autocmd BufEnter,WinEnter,WinLeave *      call s:reload()
  autocmd BufLeave *   call s:clear_hl()
aug END

"=============================================================================
let s:enc = {'\ ': ' '}
function! s:change_strs(arg) "{{{
  let b:taillight_strs = map(split(a:arg,  '\%(\\\@<!\s\)\+'), 'substitute(v:val, ''\\.'', ''\=get(s:enc, submatch(0), submatch(0))'', "g")')
  call s:reload()
endfunction
"}}}
function! s:define_hl() "{{{
  highlight default TailLight   guibg=Magenta ctermbg=Magenta term=reverse
endfunction
"}}}
function! s:clear_hl() "{{{
  if !exists('w:taillight_matchid')
    return
  end
  call matchdelete(w:taillight_matchid)
  unlet w:taillight_matchid
  let w:taillight_crr_endstrs = []
endfunction
"}}}
function! s:reload() "{{{
  if get(w:, 'taillight_crr_endstrs', []) ==# get(b:, 'taillight_strs', [])
    return
  end
  let b:taillight_strs = get(b:, 'taillight_strs', [])
  let w:taillight_crr_endstrs = b:taillight_strs
  if exists('w:taillight_matchid')
    call matchdelete(w:taillight_matchid)
  end
  if b:taillight_strs==[]
    unlet! w:taillight_matchid
    return
  end
  let w:taillight_matchid = matchadd('TailLight', s:_gen_pat())
endfunction
"}}}

"=============================================================================
"Misc:
function! s:_gen_pat() "{{{
  return '\V\%('. join(b:taillight_strs + g:taillight_regulars, '\|'). '\|\^\)\@<!\$'
endfunction
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo

if expand('<sfile>:p')!=#expand('%:p') && exists('g:loaded_taillight')| finish| endif| let g:loaded_taillight = 1
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
let g:taillight_regulars = get(g:, 'taillight_regulars', ['\m^', '{', '\m^\s*}'])
let g:taillight_magic_pat = get(g:, 'taillight_magic_pat', '\m')
command! -nargs=? -bang   TailLight    call s:turn_on(<q-args>, <bang>0)

aug TailLight
  au!
  au ColorScheme * :hi default TailLight   guibg=Magenta ctermbg=Magenta term=reverse
  au BufLeave *    call s:clear_hl()
  au BufEnter,WinEnter,WinLeave *    call s:reload()
aug END
hi default TailLight   guibg=Magenta ctermbg=Magenta term=reverse

function! s:turn_on(arg, bang) "{{{
  let b:taillight_strs = map(split(a:arg,  '\%(\\\@<!\s\)\+'), 'substitute(v:val, ''\\ '', " ", "g")')
  if b:taillight_strs!=[] && !a:bang
    call extend(b:taillight_strs, g:taillight_regulars, 0)
  end
  call s:reload()
endfunction
"}}}
function! s:clear_hl() "{{{
  if !exists('w:taillight_matchid')
    return
  end
  call matchdelete(w:taillight_matchid)
  unlet w:taillight_matchid
  let w:taillight_crrstrs = []
endfunction
"}}}
function! s:reload() "{{{
  if get(w:, 'taillight_crrstrs', []) ==# get(b:, 'taillight_strs', [])
    return
  end
  let b:taillight_strs = get(b:, 'taillight_strs', [])
  let w:taillight_crrstrs = b:taillight_strs
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
let s:magic_seppats = {'\v': '\v|', '\m': '\m\|', '\M': '\M\|', '\V': '\V\|'}
function! s:_gen_pat() "{{{
  let magic_pat = has_key(s:magic_seppats, g:taillight_magic_pat) ? g:taillight_magic_pat : '\m'
  let magic_seppat = s:magic_seppats[magic_pat]
  return '\%('.magic_pat. join(b:taillight_strs,  magic_seppat). '\m\)\@<!$'
endfunction
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo

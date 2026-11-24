" Yet another vim and tmux integration
" Maintainer: Danil Golovachev <danithecake@gmail.com>

" if !get(g:, 'loaded_tvix', 0)
"  finish
" endif

let g:loaded_tvix = 1
let g:tvix_conpaneid = !empty($TVIX_CONPANEID) ? $TVIX_CONPANEID : ':.1'

function! s:tvix_selectpane(args)
  let l:opts = {}

  let l:pane = matchstr(a:args, '-t\zs\S*\ze')
  let l:opts.pane = empty(l:pane) ? '-t'.g:tvix_conpaneid : l:pane

  if !empty(matchstr(a:args, '-Z'))
    let l:opts.zoom = 1
  endif

  let l:pos = matchstr(a:args, '-[LDUR]')
  if !empty(l:pos)
    let l:opts.pos = l:pos[1:1]
  endif

  call tvix#selectpane(l:opts)
endfunction

function! s:tvix_exec(args, bang, range, sline, eline)
  let l:cmd = a:range ? join(getline(a:sline, a:eline), '; ') : a:args
  let l:cmd = join(map(split(l:cmd), 'expand(v:val)'))
  let l:cmd = (a:bang == '!' ? ' ' : '').l:cmd

  call tvix#execute([l:cmd], {})
endfunction

command! -bang -bar -range -nargs=* -complete=shellcmd TvixExec
  \ call <SID>tvix_exec('<args>', '<bang>', <range>, <line1>, <line2>)

command! -bar -nargs=* TvixSelPane call <SID>tvix_selectpane('<args>')

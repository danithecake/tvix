" Yet another vim and tmux integration
" Maintainer: Danil Golovachev <danithecake@gmail.com>

function! s:findvar(var, ...)
  return get(w:, a:var, get(b:, a:var, get(t:, a:var, get(g:, a:var, a:1))))
endfunction

function! s:tmuxprg()
  return s:findvar('tmuxprg', 'tmux')
endfunction

function! tvix#conpaneid()
  return s:findvar('tvix_conpaneid', '')
endfunction

function! tvix#curpaneid()
  return get(systemlist('test -n "$TMUX" && tmux display-message -p "#I.#P"'), 0, '')
endfunction

function! tvix#winnew(opts)
  let args = !empty(get(a:opts, 'args', '')) ? ' -'.a:opts.args : ''
  let name = !empty(get(a:opts, 'name', '')) ? ' -n '.a:opts.name : ''
  let pane = !empty(get(a:opts, 'pane', '')) ? ' -t'.a:opts.pane : ''
  let cmd = !empty(get(a:opts, 'cmd', '')) ? ' '.shellescape(a:opts.cmd) : ''

  call system('test -n "$TMUX" && tmux new-window'.args.name.pane.cmd)
endfunction

function! tvix#selectpane(opts)
  let l:pane = ' -t'.get(a:opts, 'pane', tvix#conpaneid())
  let l:zoom = get(a:opts, 'zoom', 0) ? ' -Z' : ''

  let l:win = matchstr(l:pane, ':\zs\S*\ze\.\?')
  if !empty(l:win)
    call system(s:tmuxprg().' select-window -t:'.l:win)
  endif

  let l:title = get(a:opts, 'title', '')
  if !empty(l:title)
    let l:pane = ''
    let l:title = ' -T '.l:title
  endif

  let l:pos = get(a:opts, 'pos', '')
  if !empty(l:pos)
    let l:pane = ''
    let l:title = ''
    let l:pos = ' -'.toupper(l:pos)
  endif

  call system(s:tmuxprg().' select-pane'.l:zoom.l:pos.l:title.l:pane)
endfunction

function! tvix#copymode(opts)
  let l:args = !empty(get(a:opts, 'args', '')) ? ' -'.a:opts.args : ''
  " let l:pane = !empty(get(a:opts, 'pane', '')) ? ' -t'.a:opts.pane : ''
  let l:pane = get(a:opts, 'pane', tvix#conpaneid())
  let l:pane = !empty(l:pane) ? ' -t'.l:pane : ''

  call system(s:tmuxprg().' copy-mode'.l:args.l:pane)
endfunction

function! tvix#sendkeys(keys, opts)
  let l:args = !empty(get(a:opts, 'args', '')) ? ' -'.a:opts.args : ''
  let l:rcount = !empty(get(a:opts, 'repeat_count', '')) ? ' -N '.a:opts.repeat_count : ''
  " let l:pane = !empty(get(a:opts, 'pane', '')) ? ' -t'.a:opts.pane : ''
  let l:pane = get(a:opts, 'pane', tvix#conpaneid())
  let l:pane = !empty(l:pane) ? ' -t'.l:pane : ''

  call system(s:tmuxprg().' copy-mode -q '.l:pane.'\; send-keys'.l:args.l:rcount.l:pane.' '.a:keys)
endfunction

function! tvix#execute(input, opts)
  let l:type = !empty(get(a:opts, 'type', '')) ? a:opts.type : 'send'
  let l:input = shellescape(join(a:input))

  " call tvix#copymode({ 'args': 'q', 'pane': get(a:opts, 'pane', '') })
  call tvix#sendkeys(l:input.' C-m', a:opts)
endfunction

function! tvix#popup(input, opts)
  let l:w = ' -w '.(!empty(get(a:opts, 'w', '')) ? a:opts.w : '70%')
  let l:h = ' -h '.(!empty(get(a:opts, 'h', '')) ? a:opts.h : '70%')
  let l:redir = get(a:opts, 'redir', '')
  let l:tmpfile = tempname()

  if !empty(l:redir)
    call add(a:input, l:redir.l:tmpfile)
  endif

  call system(s:tmuxprg().' display-popup'.l:w.l:h.' -E '.shellescape(join(a:input)))

  if filereadable(l:tmpfile)
    let l:out = join(readfile(l:tmpfile))

    call delete(l:tmpfile)

    return l:out
  else
    return ''
  endif
endfunction

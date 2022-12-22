function! nvlime#ui#mrepl#InitMREPLBuf(conn, chan_obj)
  let mrepl_buf = bufnr(nvlime#ui#MREPLBufName(a:conn, a:chan_obj), v:true)
  if !nvlime#ui#NvlimeBufferInitialized(mrepl_buf)
    call nvlime#ui#SetNvlimeBufferOpts(mrepl_buf, a:conn)
    call setbufvar(mrepl_buf, 'nvlime_mrepl_channel', a:chan_obj)
    call setbufvar(mrepl_buf, '&filetype', 'nvlime_mrepl')
    call nvlime#ui#WithBuffer(mrepl_buf,
          \ function('s:InitMREPLBuf', [a:conn, a:chan_obj]))
  endif
  return mrepl_buf
endfunction

function! nvlime#ui#mrepl#ShowPrompt(buf, prompt)
  call nvlime#ui#WithBuffer(a:buf, function('s:ShowPromptOrResult', [a:prompt]))
  if bufnr('%') == a:buf
    normal! G
    call feedkeys("\<End>", 'n')
  endif
endfunction

function! nvlime#ui#mrepl#ShowResult(buf, result)
  call nvlime#ui#WithBuffer(a:buf, function('s:ShowPromptOrResult', [a:result]))
endfunction

function! s:ShowPromptOrResult(content)
  let last_line = getline('$')
  if len(last_line) > 0
    call nvlime#ui#AppendString("\n" . a:content)
  else
    call nvlime#ui#AppendString(a:content)
  endif
endfunction

function! s:InitMREPLBuf(conn, chan_obj)
  " Excessive indentation may mess up the prompt and the result strings.
  setlocal noautoindent
  setlocal nocindent
  setlocal nosmartindent
  setlocal iskeyword=@,48-57,_,192-255,+,-,*,/,%,<,=,>,:,$,?,!,@-@,94
  setlocal omnifunc=nvlime#plugin#CompleteFunc
  " TODO: Use another indentexpr that dosn't search past the last prompt
  setlocal indentexpr=nvlime#plugin#CalcCurIndent()

  call s:ShowBanner(a:conn, a:chan_obj)
endfunction

function! nvlime#ui#mrepl#Submit()
  let read_mode = b:nvlime_mrepl_channel['mrepl']['mode']
  let insert_newline = v:true

  if read_mode == 'EVAL'
    let prompt = nvlime#contrib#mrepl#BuildPrompt(b:nvlime_mrepl_channel)
    let old_pos = getcurpos()
    try
      normal! G$
      let eof_pos = getcurpos()
      if (old_pos[0] < eof_pos[0]) || (old_pos[0] == eof_pos[0] && old_pos[1] <= eof_pos[1])
        let insert_newline = v:false
      endif
      let last_prompt_pos = searchpos('\V' . prompt, 'bcenW')
    finally
      call setpos('.', old_pos)
    endtry

    let last_prompt_pos[1] += 1
    let to_send = nvlime#ui#GetText(last_prompt_pos, eof_pos[1:2])
  elseif read_mode == 'READ'
    let last_line = getline('$')
    let to_send = last_line . "\n"
  endif

  let msg = b:nvlime_conn.EmacsChannelSend(
        \ b:nvlime_mrepl_channel['mrepl']['peer'],
        \ [nvlime#KW('PROCESS'), to_send])
  call b:nvlime_conn.Send(msg)

  return insert_newline ? "\<CR>" : "\<Esc>GA\<CR>"
endfunction

function! nvlime#ui#mrepl#Clear()
  call nvlime#ClearCurrentBuffer()
  call s:ShowBanner(b:nvlime_conn, b:nvlime_mrepl_channel)
  let prompt = nvlime#contrib#mrepl#BuildPrompt(b:nvlime_mrepl_channel)
  call nvlime#ui#mrepl#ShowPrompt(bufnr('%'), prompt)
endfunction

function! nvlime#ui#mrepl#Disconnect()
  let remote_chan_id = b:nvlime_mrepl_channel['mrepl']['peer']
  let remote_chan = b:nvlime_conn['remote_channels'][remote_chan_id]
  let remote_thread = remote_chan['mrepl']['thread']
  let cmd = [nvlime#KW('EMACS-REX'),
        \ [nvlime#SYM('SWANK/BACKEND', 'KILL-THREAD'),
        \ [nvlime#SYM('SWANK/BACKEND', 'FIND-THREAD'), remote_thread]],
        \ v:null, v:true]
  call b:nvlime_conn.Send(cmd,
        \ function('nvlime#SimpleSendCB',
        \ [b:nvlime_conn,
        \ function('s:KillThreadComplete', [bufnr('%')]),
        \ 'nvlime#ui#mrepl#Disconnect']))
endfunction

function! nvlime#ui#mrepl#Interrupt()
  let remote_chan_id = b:nvlime_mrepl_channel['mrepl']['peer']
  let remote_chan = b:nvlime_conn['remote_channels'][remote_chan_id]
  call b:nvlime_conn.Interrupt(remote_chan['mrepl']['thread'])
  return ''
endfunction

function! s:KillThreadComplete(mrepl_buf, conn, _result)
  let local_chan = getbufvar(a:mrepl_buf, 'nvlime_mrepl_channel')
  execute 'bunload!' a:mrepl_buf

  call a:conn.RemoveRemoteChannel(local_chan['mrepl']['peer'])
  call a:conn.RemoveLocalChannel(local_chan['id'])
endfunction

function! s:ShowBanner(conn, chan_obj)
  let banner = 'MREPL - SWANK'
  if has_key(a:conn.cb_data, 'version')
    let banner .= ' version ' . a:conn.cb_data['version']
  endif
  if has_key(a:conn.cb_data, 'pid')
    let banner .= ', pid ' . a:conn.cb_data['pid']
  endif
  let remote_chan_id = a:chan_obj['mrepl']['peer']
  let remote_chan_obj = a:conn['remote_channels'][remote_chan_id]
  let banner .= ', thread ' . remote_chan_obj['mrepl']['thread']
  let banner_len = len(banner)
  let banner .= ("\n" . repeat('=', banner_len) . "\n")
  call nvlime#ui#AppendString(banner)
endfunction

" vim: sw=2

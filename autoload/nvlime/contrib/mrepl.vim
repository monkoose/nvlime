""
" @dict NvlimeConnection.CreateMREPL
" @usage [chan_id] [callback]
" @public
"
" Create an REPL listener using SWANK-MREPL. [chan_id] should be a unique
" number identifying the local channel. Use a automatically generated ID if
" [chan_id] is omitted or v:null.
"
" This method needs the SWANK-MREPL contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#mrepl#CreateMREPL(...) dict
  let chan_id = get(a:000, 0, v:null)
  let Callback = get(a:000, 1, v:null)
  let chan_obj = self.MakeLocalChannel(chan_id, function('s:MREPL_ChannelCB'))
  let chan_obj['mrepl'] = {'mode': 'EVAL'}
  call self.Send(self.EmacsRex([nvlime#SYM('SWANK-MREPL', 'CREATE-MREPL'), chan_obj['id']]),
        \ function('s:CreateMREPL_CB', [self, Callback, chan_obj]))
endfunction

function! nvlime#contrib#mrepl#OnMREPLWriteResult(conn, chan_obj, result) dict
  let mrepl_buf = nvlime#ui#mrepl#InitMREPLBuf(a:conn, a:chan_obj)
  call s:EnsureBufferOpen(mrepl_buf, 'mrepl')
  call nvlime#ui#mrepl#ShowResult(mrepl_buf, a:result)
endfunction

function! nvlime#contrib#mrepl#OnMREPLWriteString(conn, chan_obj, content) dict
  let mrepl_buf = nvlime#ui#mrepl#InitMREPLBuf(a:conn, a:chan_obj)
  call s:EnsureBufferOpen(mrepl_buf, 'mrepl')
  call s:AppendOutput(mrepl_buf, a:content)
endfunction

function! nvlime#contrib#mrepl#OnMREPLPrompt(conn, chan_obj) dict
  let mrepl_buf = nvlime#ui#mrepl#InitMREPLBuf(a:conn, a:chan_obj)
  call s:EnsureBufferOpen(mrepl_buf, 'mrepl')
  let prompt = nvlime#contrib#mrepl#BuildPrompt(a:chan_obj)
  call nvlime#ui#mrepl#ShowPrompt(mrepl_buf, prompt)
endfunction

function! nvlime#contrib#mrepl#BuildPrompt(chan_obj)
  return a:chan_obj['mrepl']['prompt'][1] . '> '
endfunction

function! nvlime#contrib#mrepl#Init(conn)
  let a:conn['CreateMREPL'] = function('nvlime#contrib#mrepl#CreateMREPL')
  let ui = nvlime#ui#GetUI()
  let ui['OnMREPLWriteResult'] = function('nvlime#contrib#mrepl#OnMREPLWriteResult')
  let ui['OnMREPLWriteString'] = function('nvlime#contrib#mrepl#OnMREPLWriteString')
  let ui['OnMREPLPrompt'] = function('nvlime#contrib#mrepl#OnMREPLPrompt')
endfunction

function! s:AppendOutput(repl_buf, str)
  call setbufvar(a:repl_buf, '&modifiable', 1)
  try
    call nvlime#ui#WithBuffer(a:repl_buf, function('nvlime#ui#AppendString', [a:str]))
  finally
    call setbufvar(a:repl_buf, '&modifiable', 0)
  endtry
endfunction

function! s:CreateMREPL_CB(conn, Callback, local_chan, chan, msg)
  try
    call nvlime#CheckReturnStatus(a:msg, 'nvlime#contrib#mrepl#CreateMREPL')
  catch
    let local_chan_id = a:local_chan['id']
    call a:conn.RemoveLocalChannel(local_chan_id)
    throw v:exception
  endtry
  let [chan_id, thread_id, pkg_name, pkg_prompt] = a:msg[1][1]
  let a:local_chan['mrepl']['peer'] = chan_id
  let a:local_chan['mrepl']['prompt'] = [pkg_name, pkg_prompt]
  let remote_chan = a:conn.MakeRemoteChannel(chan_id)
  let remote_chan['mrepl'] = {
        \ 'thread': thread_id,
        \ 'peer': a:local_chan['id'],
        \ }
  call nvlime#TryToCall(a:Callback, [a:conn, a:msg[1][1]])
endfunction

function! s:OnWriteResult(conn, chan_obj, msg)
  if a:conn.ui isnot v:null
    call a:conn.ui.OnMREPLWriteResult(a:conn, a:chan_obj, a:msg[1])
  endif
endfunction

function! s:OnWriteString(conn, chan_obj, msg)
  if a:conn.ui isnot v:null
    call a:conn.ui.OnMREPLWriteString(a:conn, a:chan_obj, a:msg[1])
  endif
endfunction

function! s:OnPrompt(conn, chan_obj, msg)
  let a:chan_obj['mrepl']['prompt'] = a:msg[1:2]
  if a:conn.ui isnot v:null
    call a:conn.ui.OnMREPLPrompt(a:conn, a:chan_obj)
  endif
endfunction

function! s:OnSetReadMode(conn, chan_obj, msg)
  let a:chan_obj['mrepl']['mode'] = a:msg[1]['name']
endfunction

function! s:OnEvaluationAborted(conn, chan_obj, msg)
  if a:conn.ui isnot v:null
    call a:conn.ui.OnMREPLWriteResult(a:conn, a:chan_obj, '; Evaluation aborted')
  endif
endfunction

let s:channel_event_handlers = {
      \ 'WRITE-RESULT': function('s:OnWriteResult'),
      \ 'WRITE-STRING': function('s:OnWriteString'),
      \ 'PROMPT': function('s:OnPrompt'),
      \ 'SET-READ-MODE': function('s:OnSetReadMode'),
      \ 'EVALUATION-ABORTED': function('s:OnEvaluationAborted'),
      \ }

function! s:MREPL_ChannelCB(conn, chan_obj, msg)
  let msg_type = a:msg[0]
  let Handler = get(s:channel_event_handlers, msg_type['name'], v:null)
  if Handler isnot v:null
    let ToCall = function(Handler, [a:conn, a:chan_obj, a:msg])
    call ToCall()
  elseif get(g:, '_nvlime_debug', v:false)
    echom 'Unknown message: ' . string(a:msg)
  endif
endfunction

function! s:EnsureBufferOpen(buf, win_type)
  if len(win_findbuf(a:buf)) <= 0
    call nvlime#ui#KeepCurWindow(
          \ function('nvlime#ui#OpenBufferWithWinSettings',
          \ [a:buf, v:false, a:win_type]))
  endif
endfunction

" vim: sw=2

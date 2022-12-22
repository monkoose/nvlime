""
" @dict NvlimeConnection.CreateREPL
" @public
"
" Create the REPL thread, and optionally register a [callback] function to
" handle the result.
"
" [coding_system] is implementation-dependent. Omit this argument or pass
" v:null to let the server choose it for you.
"
" This method needs the SWANK-REPL contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#repl#CreateREPL(coding_system = v:null, Callback = v:null) dict
  function! s:CreateREPL_CB(conn, Cb, chan, msg) abort
    call nvlime#CheckReturnStatus(a:msg, 'nvlime#contrib#repl#CreateREPL')
    " The package for the REPL defaults to ['COMMON-LISP-USER', 'CL-USER'],
    " so SetCurrentPackage(...) is not necessary.
    "call a:conn.SetCurrentPackage(a:msg[1][1])
    call nvlime#TryToCall(a:Cb, [a:conn, a:msg[1][1]])
  endfunction

  let cmd = [nvlime#SYM('SWANK-REPL', 'CREATE-REPL'), v:null]
  if a:coding_system isnot v:null
    let cmd += [nvlime#KW('CODING-SYSTEM'), a:coding_system]
  endif
  call self.Send(self.EmacsRex(cmd),
        \ function('s:CreateREPL_CB', [self, a:Callback]))
endfunction

""
" @dict NvlimeConnection.ListenerEval
" @public
"
" Evaluate {expr} in the current package and thread, and optionally register a
" [callback] function to handle the result.
" {expr} should be a plain string containing the lisp expression to be
" evaluated.
"
" This method needs the SWANK-REPL contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#repl#ListenerEval(expr, Callback = v:null) dict
  function! s:ListenerEvalCB(conn, Cb, chan, msg) abort
    let stat = s:CheckAndReportReturnStatus(a:conn, a:msg,
          \ 'nvlime#contrib#repl#ListenerEval')
    if stat
      call nvlime#TryToCall(a:Cb, [a:conn, a:msg[1][1]])
    endif
  endfunction

  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-REPL', 'LISTENER-EVAL'), a:expr]),
        \ function('s:ListenerEvalCB', [self, a:Callback]))
endfunction

function! nvlime#contrib#repl#Init(conn)
  let a:conn['CreateREPL'] = function('nvlime#contrib#repl#CreateREPL')
  let a:conn['ListenerEval'] = function('nvlime#contrib#repl#ListenerEval')
  call a:conn.CreateREPL(v:null)
endfunction

function! s:CheckAndReportReturnStatus(conn, return_msg, caller)
  let status = a:return_msg[1][0]
  if status['name'] == 'OK'
    return v:true
  elseif status['name'] == 'ABORT'
    call a:conn.ui.OnWriteString(a:conn, a:return_msg[1][1] . "\n",
          \ {'name': 'ABORT-REASON', 'package': 'KEYWORD'})
    return v:false
  else
    call a:conn.ui.OnWriteString(a:conn, string(a:return_msg[1]),
          \ {'name': 'UNKNOWN-ERROR', 'package': 'KEYWORD'})
    return v:false
  endif
endfunction

" vim: sw=2

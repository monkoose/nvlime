""
" @dict NvlimeConnection
" Nvlime uses @dict(NvlimeConnection) objects to represent connections to the
" servers. You can create such an object by calling
" @function(nvlime#plugin#ConnectREPL) or @function(nvlime#New).
"
" Most of the connection object's methods are thin wrappers around raw
" SLIME/SWANK messages, and they are asynchronous. These async methods have an
" optional callback argument, to allow a function be registered for handling
" the result returned by the server. The callback functions should accept two
" arguments:
"
"     function! SomeCallbackFunc({conn_obj}, {result}) ...
"
" {conn_obj} is the connection object in question, and {result} is the
" returned value.
"
" See below for a detailed list of methods for @dict(NvlimeConnection) objects.
"

""
" @usage [cb_data] [ui]
" @public
"
" Create a @dict(NvlimeConnection).
"
" [cb_data] is arbitrary data, accessible from the connection callbacks.
" [ui] is an instance of @dict(NvlimeUI), see @function(nvlime#ui#GetUI).
"
" This function is seldom used directly. To connect to a server, call
" @function(nvlime#plugin#ConnectREPL).
function! nvlime#New(cb_data = v:null, ui = v:null)
  let obj = {
        \ 'cb_data': a:cb_data,
        \ 'channel': v:null,
        \ 'remote_prefix': '',
        \ 'ping_tag': 1,
        \ 'next_local_channel_id': 1,
        \ 'local_channels': {},
        \ 'remote_channels': {},
        \ 'ui': a:ui,
        \ 'Connect': function('nvlime#Connect'),
        \ 'IsConnected': function('nvlime#IsConnected'),
        \ 'Close': function('nvlime#Close'),
        \ 'Call': function('nvlime#Call'),
        \ 'Send': function('nvlime#Send'),
        \ 'FixRemotePath': function('nvlime#FixRemotePath'),
        \ 'FixLocalPath': function('nvlime#FixLocalPath'),
        \ 'GetCurrentPackage': function('nvlime#GetCurrentPackage'),
        \ 'SetCurrentPackage': function('nvlime#SetCurrentPackage'),
        \ 'GetCurrentThread': function('nvlime#GetCurrentThread'),
        \ 'SetCurrentThread': function('nvlime#SetCurrentThread'),
        \ 'WithPackage': function('nvlime#WithPackage'),
        \ 'WithThread': function('nvlime#WithThread'),
        \ 'MakeLocalChannel': function('nvlime#MakeLocalChannel'),
        \ 'RemoveLocalChannel': function('nvlime#RemoveLocalChannel'),
        \ 'MakeRemoteChannel': function('nvlime#MakeRemoteChannel'),
        \ 'RemoveRemoteChannel': function('nvlime#RemoveRemoteChannel'),
        \ 'EmacsChannelSend': function('nvlime#EmacsChannelSend'),
        \ 'EmacsRex': function('nvlime#EmacsRex'),
        \ 'Ping': function('nvlime#Ping'),
        \ 'Pong': function('nvlime#Pong'),
        \ 'ConnectionInfo': function('nvlime#ConnectionInfo'),
        \ 'SwankRequire': function('nvlime#SwankRequire'),
        \ 'SetPackage': function('nvlime#SetPackage'),
        \ 'DescribeSymbol': function('nvlime#DescribeSymbol'),
        \ 'OperatorArgList': function('nvlime#OperatorArgList'),
        \ 'SimpleCompletions': function('nvlime#SimpleCompletions'),
        \ 'ReturnString': function('nvlime#ReturnString'),
        \ 'Return': function('nvlime#Return'),
        \ 'SwankMacroExpandOne': function('nvlime#SwankMacroExpandOne'),
        \ 'SwankMacroExpand': function('nvlime#SwankMacroExpand'),
        \ 'SwankMacroExpandAll': function('nvlime#SwankMacroExpandAll'),
        \ 'DisassembleForm': function('nvlime#DisassembleForm'),
        \ 'CompileStringForEmacs': function('nvlime#CompileStringForEmacs'),
        \ 'CompileFileForEmacs': function('nvlime#CompileFileForEmacs'),
        \ 'LoadFile': function('nvlime#LoadFile'),
        \ 'XRef': function('nvlime#XRef'),
        \ 'FindDefinitionsForEmacs': function('nvlime#FindDefinitionsForEmacs'),
        \ 'FindSourceLocationForEmacs': function('nvlime#FindSourceLocationForEmacs'),
        \ 'AproposListForEmacs': function('nvlime#AproposListForEmacs'),
        \ 'DocumentationSymbol': function('nvlime#DocumentationSymbol'),
        \ 'Interrupt': function('nvlime#Interrupt'),
        \ 'SLDBAbort': function('nvlime#SLDBAbort'),
        \ 'SLDBBreak': function('nvlime#SLDBBreak'),
        \ 'SLDBContinue': function('nvlime#SLDBContinue'),
        \ 'SLDBStep': function('nvlime#SLDBStep'),
        \ 'SLDBNext': function('nvlime#SLDBNext'),
        \ 'SLDBOut': function('nvlime#SLDBOut'),
        \ 'SLDBReturnFromFrame': function('nvlime#SLDBReturnFromFrame'),
        \ 'SLDBDisassemble': function('nvlime#SLDBDisassemble'),
        \ 'InvokeNthRestartForEmacs': function('nvlime#InvokeNthRestartForEmacs'),
        \ 'RestartFrame': function('nvlime#RestartFrame'),
        \ 'FrameLocalsAndCatchTags': function('nvlime#FrameLocalsAndCatchTags'),
        \ 'FrameSourceLocation': function('nvlime#FrameSourceLocation'),
        \ 'EvalStringInFrame': function('nvlime#EvalStringInFrame'),
        \ 'InitInspector': function('nvlime#InitInspector'),
        \ 'InspectorReinspect': function('nvlime#InspectorReinspect'),
        \ 'InspectorRange': function('nvlime#InspectorRange'),
        \ 'InspectNthPart': function('nvlime#InspectNthPart'),
        \ 'InspectorCallNthAction': function('nvlime#InspectorCallNthAction'),
        \ 'InspectorPop': function('nvlime#InspectorPop'),
        \ 'InspectorNext': function('nvlime#InspectorNext'),
        \ 'InspectCurrentCondition': function('nvlime#InspectCurrentCondition'),
        \ 'InspectInFrame': function('nvlime#InspectInFrame'),
        \ 'InspectFrameVar': function('nvlime#InspectFrameVar'),
        \ 'ListThreads': function('nvlime#ListThreads'),
        \ 'KillNthThread': function('nvlime#KillNthThread'),
        \ 'DebugNthThread': function('nvlime#DebugNthThread'),
        \ 'UndefineFunction': function('nvlime#UndefineFunction'),
        \ 'UninternSymbol': function('nvlime#UninternSymbol'),
        \ 'OnServerEvent': function('nvlime#OnServerEvent'),
        \ 'server_event_handlers': {
        \ 'PING': function('nvlime#OnPing'),
        \ 'NEW-PACKAGE': function('nvlime#OnNewPackage'),
        \ 'DEBUG': function('nvlime#OnDebug'),
        \ 'DEBUG-ACTIVATE': function('nvlime#OnDebugActivate'),
        \ 'DEBUG-RETURN': function('nvlime#OnDebugReturn'),
        \ 'WRITE-STRING': function('nvlime#OnWriteString'),
        \ 'READ-STRING': function('nvlime#OnReadString'),
        \ 'READ-FROM-MINIBUFFER': function('nvlime#OnReadFromMiniBuffer'),
        \ 'INDENTATION-UPDATE': function('nvlime#OnIndentationUpdate'),
        \ 'NEW-FEATURES': function('nvlime#OnNewFeatures'),
        \ 'INVALID-RPC': function('nvlime#OnInvalidRPC'),
        \ 'INSPECT': function('nvlime#OnInspect'),
        \ 'CHANNEL-SEND': function('nvlime#OnChannelSend'),
        \ }
        \ }
  return obj
endfunction

" ================== methods for nvlime connections ==================

""
" @dict NvlimeConnection.Connect
" @public
"
" Connect to a server.
"
" {host} and {port} specify the server to connect to.
" [prefix], if specified, is an SFTP URL prefix, to tell Nvlime to open
" remote files via SFTP (see |nvlime-remote-server|).
" [timeout] is the time to wait for the connection to be made, in
" milliseconds.
function! nvlime#Connect(host, port, prefix = '', timeout = v:null) dict
  let self.channel = nvlime#async#ch_open(a:host, a:port,
        \ {chan, msg -> self.OnServerEvent(chan, msg)},
        \ a:timeout)
  if !self.channel['is_connected']
    call self.Close()
    throw 'nvlime#Connect: failed to open channel'
  endif

  let self['remote_prefix'] = a:prefix

  return self
endfunction

""
" @dict NvlimeConnection.IsConnected
" @public
"
" Return |TRUE| for a connected connection, |FALSE| otherwise.
  function! nvlime#IsConnected() dict
    return self.channel isnot v:null && self.channel['is_connected']
  endfunction

  ""
  " @dict NvlimeConnection.Close
  " @public
  "
  " Close this connection.
  function! nvlime#Close() dict
    if self.channel isnot v:null
      try
        if self.channel.ch_id
          call chanclose(self.channel.ch_id)
        endif
      catch /^Vim\%((\a\+)\)\=:E900/  " Invalid ch id
      endtry
      let self.channel = v:null
    endif
    return self
  endfunction

  ""
  " @dict NvlimeConnection.Call
  " @public
  "
  " Send a raw message {msg} to the server, and wait for a reply.
  function! nvlime#Call(msg) dict
    return nvlime#async#ch_evalexpr(self.channel, a:msg)
  endfunction

  ""
  " @dict NvlimeConnection.Send
  " @public
  "
  " Send a raw message {msg} to the server, and optionally register an async
  " [callback] function to handle the reply.
  function! nvlime#Send(msg, Callback = v:null) dict
    call nvlime#async#ch_sendexpr(self.channel, a:msg, a:Callback)
  endfunction

  ""
  " @dict NvlimeConnection.FixRemotePath
  " @public
  "
  " Fix the remote file paths after they are received from the server, so that
  " Vim can open the files via SFTP.
  " {path} can be a plain string or a Swank source location object.
  function! nvlime#FixRemotePath(path) dict
    if type(a:path) == v:t_string
      return self['remote_prefix'] . a:path
    elseif type(a:path) == v:t_list && type(a:path[0]) == v:t_dict
          \ && a:path[0]['name'] == 'LOCATION'
      if a:path[1][0]['name'] == 'FILE'
        let a:path[1][1] = self['remote_prefix'] . a:path[1][1]
      elseif a:path[1][0]['name'] == 'BUFFER-AND-FILE'
        let a:path[1][2] = self['remote_prefix'] . a:path[1][2]
      endif
      return a:path
    else
      throw 'nvlime#FixRemotePath: unknown path: ' . string(a:path)
    endif
  endfunction

  ""
  " @dict NvlimeConnection.FixLocalPath
  " @public
  "
  " Fix the local file paths before sending them to the server, so that the
  " server can see the correct files.
  " {path} should be a plain string or v:null.
  function! nvlime#FixLocalPath(path) dict
    if type(a:path) != v:t_string
      return a:path
    endif

    let prefix_len = len(self['remote_prefix'])
    if prefix_len > 0 && a:path[0:prefix_len-1] == self['remote_prefix']
      return a:path[prefix_len:]
    else
      return a:path
    endif
  endfunction

  ""
  " @dict NvlimeConnection.GetCurrentPackage
  " @public
  "
  " Return the Common Lisp package bound to the current buffer. See
  " |nvlime-current-package|.
  function! nvlime#GetCurrentPackage() dict
    if self.ui isnot v:null
      return self.ui.GetCurrentPackage()
    else
      return v:null
    endif
  endfunction

  ""
  " @dict NvlimeConnection.SetCurrentPackage
  " @public
  "
  " Bind a Common Lisp package to the current buffer. See
  " |nvlime-current-package|. This method does NOT check whether the argument is
  " a valid package. See @function(NvlimeConnection.SetPackage) for a safer
  " alternative.
  function! nvlime#SetCurrentPackage(package) dict
    if self.ui isnot v:null
      call self.ui.SetCurrentPackage(a:package)
    endif
  endfunction

  ""
  " @dict NvlimeConnection.GetCurrentThread
  " @public
  "
  " Return the thread bound to the current buffer. Currently this method only
  " makes sense in the debugger buffer.
  function! nvlime#GetCurrentThread() dict
    if self.ui isnot v:null
      return self.ui.GetCurrentThread()
    else
      return v:true
    endif
  endfunction

  ""
  " @dict NvlimeConnection.SetCurrentThread
  " @public
  "
  " Bind a thread to the current buffer. Don't call this method directly, unless
  " you know what you're doing.
  function! nvlime#SetCurrentThread(thread) dict
    if self.ui isnot v:null
      call self.ui.SetCurrentThread(a:thread)
    endif
  endfunction

  ""
  " @dict NvlimeConnection.WithThread
  " @public
  "
  " Call {Func} with {thread} set as the current thread. The current thread will
  " be reset once this method returns. This is useful when you want to e.g.
  " evaluate something in certain threads.
  function! nvlime#WithThread(thread, Func) dict
    let old_thread = self.GetCurrentThread()
    try
      call self.SetCurrentThread(a:thread)
      return a:Func()
    finally
      call self.SetCurrentThread(old_thread)
    endtry
  endfunction

  ""
  " @dict NvlimeConnection.WithPackage
  " @public
  "
  " Call {Func} with {package} set as the current package. The current package
  " will be reset once this method returns.
  function! nvlime#WithPackage(package, Func) dict
    let old_package = self.GetCurrentPackage()
    try
      call self.SetCurrentPackage([a:package, a:package])
      return a:Func()
    finally
      call self.SetCurrentPackage(old_package)
    endtry
  endfunction

  ""
  " @dict NvlimeConnection.MakeLocalChannel
  " @public
  "
  " Create a local channel (in the sense of SLIME channels). [chan_id], if
  " provided and not v:null, should be be a unique integer to identify the new
  " channel. A new ID will be generated if [chan_id] is omitted or v:null.
  " [callback] is a function responsible for handling the messages directed to
  " this very channel. It should have such a signature:
  "
  "   SomeCallbackFunction(<conn>, <chan>, <msg>)
  "
  " <conn> is a @dict(NvlimeConnection) object. <chan> is the channel object in
  " question, and <msg> is the channel message received from the server.
  function! nvlime#MakeLocalChannel(chan_id = v:null, Callback = v:null) dict
    let c_id = a:chan_id
    if c_id is v:null
      let c_id = self['next_local_channel_id']
      let self['next_local_channel_id'] += 1
    endif

    if has_key(self['local_channels'], c_id)
      throw 'nvlime#MakeLocalChannel: channel ' .. c_id .. ' already exists'
    endif

    let chan_obj = { 'id': c_id, 'callback': a:Callback }
    let self['local_channels'][c_id] = chan_obj
    return chan_obj
  endfunction

  ""
  " @dict NvlimeConnection.RemoveLocalChannel
  " @public
  "
  " Remove a local channel with the ID {chan_id}.
  function! nvlime#RemoveLocalChannel(chan_id) dict
    call remove(self['local_channels'], a:chan_id)
  endfunction

  ""
  " @dict NvlimeConnection.MakeRemoteChannel
  " @usage {chan_id}
  " @public
  "
  " Save the info for a remote channel (in the sense of SLIME channels).
  " {chan_id} should be an ID assigned by the server.
  function! nvlime#MakeRemoteChannel(chan_id) dict
    if has_key(self['remote_channels'], a:chan_id)
      throw 'nvlime#MakeRemoteChannel: channel ' . a:chan_id . ' already exists'
    endif

    let chan_obj = {'id': a:chan_id}
    let self['remote_channels'][a:chan_id] = chan_obj
    return chan_obj
  endfunction

  ""
  " @dict NvlimeConnection.RemoveRemoteChannel
  " @public
  "
  " Remove a remote channel with the ID {chan_id}
  function! nvlime#RemoveRemoteChannel(chan_id) dict
    call remove(self['remote_channels'], a:chan_id)
  endfunction

  ""
  " @dict NvlimeConnection.EmacsChannelSend
  " @public
  "
  " Construct an :EMACS-CHANNEL-SEND message. {chan_id} should be the destination
  " remote channel ID, and {msg} is the message to be sent. Note that, despite
  " the word "Send" in its name, this function WILL NOT send the constructed
  " message. You still need to call @function(NvlimeConnection.Send) for that.
  function! nvlime#EmacsChannelSend(chan_id, msg) dict
    if !has_key(self['remote_channels'], a:chan_id)
      throw 'nvlime#EmacsChannelSend: channel ' . a:chan_id . ' does not exist'
    else
      return [s:KW('EMACS-CHANNEL-SEND'), a:chan_id, a:msg]
    endif
  endfunction

  ""
  " @dict NvlimeConnection.EmacsRex
  " @public
  "
  " Construct an :EMACS-REX message, with the current package and the current
  " thread.
  " {cmd} should be a raw :EMACS-REX command.
  function! nvlime#EmacsRex(cmd) dict
    let pkg_info = self.GetCurrentPackage()
    if type(pkg_info) != v:t_list
      let pkg = v:null
    else
      let pkg = pkg_info[0]
    endif
    return s:EmacsRex(a:cmd, pkg, self.GetCurrentThread())
  endfunction

  ""
  " @dict NvlimeConnection.Ping
  " @public
  "
  " Send a PING request to the server, and wait for the reply.
  function! nvlime#Ping() dict
    let cur_tag = self.ping_tag
    let self.ping_tag = (self.ping_tag >= 65536) ? 1 : (self.ping_tag + 1)

    let result = self.Call(self.EmacsRex([s:SYM('SWANK', 'PING'), cur_tag]))
    if type(result) == v:t_string && len(result) == 0
      " Error or timeout
      throw 'nvlime#Ping: failed'
    endif

    call s:CheckReturnStatus(result, 'nvlime#Ping')
    if result[1][1] != cur_tag
      throw 'nvlime#Ping: bad tag'
    endif
  endfunction

  ""
  " @dict NvlimeConnection.Pong
  " @private
  "
  " Reply to server PING messages.
  " {thread} and {ttag} are parameters received in the PING message from the
  " server.
  function! nvlime#Pong(thread, ttag) dict
    call self.Send([s:KW('EMACS-PONG'), a:thread, a:ttag])
  endfunction

  ""
  " @dict NvlimeConnection.ConnectionInfo
  " @public
  "
  " Ask the server for some info regarding this connection, and optionally
  " register a [callback] function to handle the result.
  "
  " If [return_dict] is specified and |TRUE|, this method will convert the
  " result to a dictionary before passing it to the [callback] function.
  function! nvlime#ConnectionInfo(return_dict = v:true, Callback = v:null) dict
    " We pass local variables as extra arguments instead of
    " using the 'closure' flag on inner functions, to prevent
    " messed-up variable values caused by calling the outer
    " function more than once.
    function! s:ConnectionInfoCB(conn, Cb, ret_dict, chan, msg) abort
      call s:CheckReturnStatus(a:msg, 'nvlime#ConnectionInfo')
      if a:ret_dict
        call s:TryToCall(a:Cb, [a:conn, nvlime#PListToDict(a:msg[1][1])])
      else
        call s:TryToCall(a:Cb, [a:conn, a:msg[1][1]])
      endif
    endfunction

    call self.Send(self.EmacsRex([s:SYM('SWANK', 'CONNECTION-INFO')]),
          \ function('s:ConnectionInfoCB', [self, a:Callback, a:return_dict]))
  endfunction

  ""
  " @dict NvlimeConnection.SwankRequire
  " @public
  "
  " Require Swank contrib modules, and optionally register a [callback] function
  " to handle the result.
  "
  " {contrib} can be a string or a list of strings. Each string is a contrib
  " module name. These names are case-sensitive. Normally you should use
  " uppercase.
  "
  " For example, "conn_obj.SwankRequire('SWANK-REPL')" tells Swank to load the
  " SWANK-REPL contrib module, and "conn_obj.SwankRequire(['SWANK-REPL',
  " 'SWANK-PRESENTATIONS'])" tells Swank to load both SWANK-REPL and
  " SWANK-PRESENTATIONS.
  function! nvlime#SwankRequire(contrib, Callback = v:null) dict
    if type(a:contrib) == v:t_list
      let required = [s:CL('QUOTE'), map(copy(a:contrib), {k, v -> s:KW(v)})]
    else
      let required = s:KW(a:contrib)
    endif

    call self.Send(self.EmacsRex([s:SYM('SWANK', 'SWANK-REQUIRE'), required]),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#SwankRequire']))
  endfunction

  ""
  " @dict NvlimeConnection.Interrupt
  " @public
  "
  " Interrupt {thread}.
  " {thread} should be a numeric thread ID, or {"package": "KEYWORD", "name":
  " "REPL-THREAD"} for the REPL thread. The debugger will be activated upon
  " interruption.
  function! nvlime#Interrupt(thread) dict
    call self.Send([s:KW('EMACS-INTERRUPT'), a:thread])
  endfunction

  ""
  " @dict NvlimeConnection.SLDBAbort
  " @usage [callback]
  " @public
  "
  " When the debugger is active, invoke the ABORT restart.
  function! nvlime#SLDBAbort(Callback = v:null) dict
    call self.Send(self.EmacsRex([s:SYM('SWANK', 'SLDB-ABORT')]),
          \ function('s:SLDBSendCB', [self, a:Callback, 'nvlime#SLDBAbort']))
  endfunction

  ""
  " @dict NvlimeConnection.SLDBBreak
  " @public
  "
  " Set a breakpoint at entry to a function with the name {func_name}.
  function! nvlime#SLDBBreak(func_name, Callback = v:null) dict
    call self.Send(self.EmacsRex([s:SYM('SWANK', 'SLDB-BREAK'), a:func_name]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#SLDBBreak']))
  endfunction

  ""
  " @dict NvlimeConnection.SLDBContinue
  " @public
  "
  " When the debugger is active, invoke the CONTINUE restart.
  function! nvlime#SLDBContinue(Callback = v:null) dict
    call self.Send(self.EmacsRex([s:SYM('SWANK', 'SLDB-CONTINUE')]),
          \ function('s:SLDBSendCB', [self, a:Callback, 'nvlime#SLDBContinue']))
  endfunction

  ""
  " @dict NvlimeConnection.SLDBStep
  " @public
  "
  " When the debugger is active, enter stepping mode in {frame}.
  " {frame} should be a valid frame number presented by the debugger.
  function! nvlime#SLDBStep(frame, Callback = v:null) dict
    call self.Send(self.EmacsRex([s:SYM('SWANK', 'SLDB-STEP'), a:frame]),
          \ function('s:SLDBSendCB', [self, a:Callback, 'nvlime#SLDBStep']))
  endfunction

  ""
  " @dict NvlimeConnection.SLDBNext
  " @public
  "
  " When the debugger is active, step over the current function call in {frame}.
  function! nvlime#SLDBNext(frame, Callback = v:null) dict
    call self.Send(self.EmacsRex([s:SYM('SWANK', 'SLDB-NEXT'), a:frame]),
          \ function('s:SLDBSendCB', [self, a:Callback, 'nvlime#SLDBNext']))
  endfunction

  ""
  " @dict NvlimeConnection.SLDBOut
  " @public
  "
  " When the debugger is active, step out of the current function in {frame}.
  function! nvlime#SLDBOut(frame, Callback = v:null) dict
    call self.Send(self.EmacsRex([s:SYM('SWANK', 'SLDB-OUT'), a:frame]),
          \ function('s:SLDBSendCB', [self, a:Callback, 'nvlime#SLDBOut']))
  endfunction

  ""
  " @dict NvlimeConnection.SLDBReturnFromFrame
  " @public
  "
  " When the debugger is active, evaluate {str} and return from {frame} with the
  " evaluation result.
  " {str} should be a plain string containing the lisp expression to be
  " evaluated.
  function! nvlime#SLDBReturnFromFrame(frame, str, Callback = v:null) dict
    call self.Send(self.EmacsRex([s:SYM('SWANK', 'SLDB-RETURN-FROM-FRAME'), a:frame, a:str]),
          \ function('s:SLDBSendCB',
          \ [self, a:Callback, 'nvlime#SLDBReturnFromFrame']))
  endfunction

  ""
  " @dict NvlimeConnection.SLDBDisassemble
  " @public
  "
  " Disassemble the code for {frame}.
  function! nvlime#SLDBDisassemble(frame, Callback = v:null) dict
    call self.Send(self.EmacsRex([s:SYM('SWANK', 'SLDB-DISASSEMBLE'), a:frame]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#SLDBDisassemble']))
  endfunction

  ""
  " @dict NvlimeConnection.InvokeNthRestartForEmacs
  " @public
  "
  " When the debugger is active, invoke a {restart} at {level}.
  " {restart} should be a valid restart number, and {level} a valid debugger
  " level.
  function! nvlime#InvokeNthRestartForEmacs(level, restart, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'INVOKE-NTH-RESTART-FOR-EMACS'), a:level, a:restart]),
          \ function('s:SLDBSendCB', [self, a:Callback, 'nvlime#InvokeNthRestartForEmacs']))
  endfunction

  ""
  " @dict NvlimeConnection.RestartFrame
  " @public
  "
  " When the debugger is active, restart a {frame}.
  function! nvlime#RestartFrame(frame, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'RESTART-FRAME'), a:frame]),
          \ function('s:SLDBSendCB',
          \ [self, a:Callback, 'nvlime#RestartFrame']))
  endfunction

  ""
  " @dict NvlimeConnection.FrameLocalsAndCatchTags
  " @public
  "
  " When the debugger is active, get info about local variables and catch tags
  " for {frame}.
  function! nvlime#FrameLocalsAndCatchTags(frame, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'FRAME-LOCALS-AND-CATCH-TAGS'), a:frame]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#FrameLocalsAndCatchTags']))
  endfunction

  ""
  " @dict NvlimeConnection.FrameSourceLocation
  " @usage {frame} [callback]
  " @public
  "
  " When the debugger is active, get the source location for {frame}.
  function! nvlime#FrameSourceLocation(frame, Callback = v:null) dict
    function! s:FrameSourceLocationCB(conn, Cb, chan, msg)
      call s:CheckReturnStatus(a:msg,  'nvlime#FrameSourceLocation')
      if a:msg[1][1][0]['name'] == 'LOCATION'
        let fixed_loc = a:conn.FixRemotePath(a:msg[1][1])
      else
        let fixed_loc = a:msg[1][1]
      endif
      call s:TryToCall(a:Cb, [a:conn, fixed_loc])
    endfunction

    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'FRAME-SOURCE-LOCATION'), a:frame]),
          \ function('s:FrameSourceLocationCB', [self, a:Callback]))
  endfunction

  ""
  " @dict NvlimeConnection.EvalStringInFrame
  " @public
  "
  " When the debugger is active, evaluate {str} in {package}, and within the
  " context of {frame}.
  function! nvlime#EvalStringInFrame(str, frame, package, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'EVAL-STRING-IN-FRAME'),
          \ a:str, a:frame, a:package]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#EvalStringInFrame']))
  endfunction

  ""
  " @dict NvlimeConnection.InitInspector
  " @public
  "
  " Evaluate {thing} and start inspecting the evaluation result with the
  " inspector.
  " {thing} should be a plain string containing the lisp expression to be
  " evaluated.
  function! nvlime#InitInspector(thing, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'INIT-INSPECTOR'), a:thing]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#InitInspector']))
  endfunction

  ""
  " @dict NvlimeConnection.InspectorReinspect
  " @public
  "
  " Reload the object being inspected, and update inspector states.
  function! nvlime#InspectorReinspect(Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'INSPECTOR-REINSPECT')]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#InspectorReinspect']))
  endfunction

  ""
  " @dict NvlimeConnection.InspectorRange
  " @public
  "
  " Pagination for inspector content.
  " {r_start} is the first index to retrieve in the inspector content list.
  " {r_end} is the last index plus one.
  function! nvlime#InspectorRange(r_start, r_end, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'INSPECTOR-RANGE'), a:r_start, a:r_end]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#InspectorRange']))
  endfunction

  ""
  " @dict NvlimeConnection.InspectNthPart
  " @public
  "
  " Inspect an object presented by the inspector.
  " {nth} should be a valid part number presented by the inspector.
  function! nvlime#InspectNthPart(nth, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'INSPECT-NTH-PART'), a:nth]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#InspectNthPart']))
  endfunction

  ""
  " @dict NvlimeConnection.InspectorCallNthAction
  " @public
  "
  " Perform an action in the inspector.
  " {nth} should be a valid action number presented by the inspector.
  function! nvlime#InspectorCallNthAction(nth, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'INSPECTOR-CALL-NTH-ACTION'), a:nth]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#InspectorCallNthAction']))
  endfunction

  ""
  " @dict NvlimeConnection.InspectorPop
  " @public
  "
  " Inspect the previous object in the stack of inspected objects.
  function! nvlime#InspectorPop(Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'INSPECTOR-POP')]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#InspectorPop']))
  endfunction

  ""
  " @dict NvlimeConnection.InspectorNext
  " @public
  "
  " Inspect the next object in the stack of inspected objects.
  function! nvlime#InspectorNext(Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'INSPECTOR-NEXT')]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#InspectorNext']))
  endfunction

  ""
  " @dict NvlimeConnection.InspectCurrentCondition
  " @public
  "
  " When the debugger is active, inspect the current condition.
  function! nvlime#InspectCurrentCondition(Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'INSPECT-CURRENT-CONDITION')]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#InspectCurrentCondition']))
  endfunction

  ""
  " @dict NvlimeConnection.InspectInFrame
  " @public
  "
  " When the debugger is active, evaluate {thing} in the context of {frame}, and
  " start inspecting the evaluation result.
  function! nvlime#InspectInFrame(thing, frame, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'INSPECT-IN-FRAME'), a:thing, a:frame]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#InspectInFrame']))
  endfunction

  ""
  " @dict NvlimeConnection.InspectFrameVar
  " @public
  "
  " When the debugger is active, inspect variable #{var_num} in the context of {frame}.
  function! nvlime#InspectFrameVar(var_num, frame, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'INSPECT-FRAME-VAR'), a:frame, a:var_num]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#InspectFrameVar']))
  endfunction

  ""
  " @dict NvlimeConnection.ListThreads
  " @public
  "
  " Get a list of running threads.
  function! nvlime#ListThreads(Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'LIST-THREADS')]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#ListThreads']))
  endfunction

  ""
  " @dict NvlimeConnection.KillNthThread
  " @public
  "
  " Kill a thread presented in the thread list.
  " {nth} should be a valid index in the thread list, instead of a thread ID.
  function! nvlime#KillNthThread(nth, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'KILL-NTH-THREAD'), a:nth]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#KillNthThread']))
  endfunction

  ""
  " @dict NvlimeConnection.DebugNthThread
  " @public
  "
  " Activate the debugger in a thread presented in the thread list.
  " {nth} should be a valid index in the thread list, instead of a thread ID.
  function! nvlime#DebugNthThread(nth, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'DEBUG-NTH-THREAD'), a:nth]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#DebugNthThread']))
  endfunction

  ""
  " @dict NvlimeConnection.UndefineFunction
  " @public
  "
  " Undefine a function with the name {func_name}.
  function! nvlime#UndefineFunction(func_name, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'UNDEFINE-FUNCTION'), a:func_name]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#UndefineFunction']))
  endfunction

  ""
  " @dict NvlimeConnection.UninternSymbol
  " @public
  "
  " Unintern a symbol with the name {sym_name}.
  " {sym_name} should be a plain string containing the name of the symbol to be
  " uninterned.
  function! nvlime#UninternSymbol(sym_name, package = v:null, Callback = v:null) dict
    let pkg = a:package
    if pkg is v:null
      let pkg_info = self.GetCurrentPackage()
      if type(pkg_info) == v:t_list
        let pkg = pkg_info[0]
      endif
    endif

    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'UNINTERN-SYMBOL'), a:sym_name, pkg]),
          \ function('nvlime#SimpleSendCB',
          \ [self, a:Callback, 'nvlime#UninternSymbol']))
  endfunction

  ""
  " @dict NvlimeConnection.SetPackage
  " @public
  "
  " Bind a Common Lisp package to the current buffer. See
  " |nvlime-current-package|.
  function! nvlime#SetPackage(package, Callback = v:null) dict
    function! s:SetPackageCB(conn, buf, Cb, chan, msg) abort
      call s:CheckReturnStatus(a:msg, 'nvlime#SetPackage')
      call nvlime#ui#WithBuffer(a:buf, function(a:conn.SetCurrentPackage, [a:msg[1][1]]))
      call s:TryToCall(a:Cb, [a:conn, a:msg[1][1]])
    endfunction

    call self.Send(self.EmacsRex([s:SYM('SWANK', 'SET-PACKAGE'), a:package]),
          \ function('s:SetPackageCB', [self, bufnr('%'), a:Callback]))
  endfunction

  ""
  " @dict NvlimeConnection.DescribeSymbol
  " @public
  "
  " Get a description for {symbol}.
  " {symbol} should be a plain string containing the symbol name.
  function! nvlime#DescribeSymbol(symbol, Callback = v:null) dict
    call self.Send(self.EmacsRex([s:SYM('SWANK', 'DESCRIBE-SYMBOL'), a:symbol]),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#DescribeSymbol']))
  endfunction

  ""
  " @dict NvlimeConnection.OperatorArgList
  " @public
  "
  " Get the arglist description for {operator}.
  " {operator} should be a plain string containing a symbol name.
  function! nvlime#OperatorArgList(operator, Callback = v:null) dict
    let cur_package = self.GetCurrentPackage()
    if cur_package isnot v:null
      let cur_package = cur_package[0]
    endif
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'OPERATOR-ARGLIST'), a:operator, cur_package]),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#OperatorArgList']))
  endfunction

  ""
  " @dict NvlimeConnection.SimpleCompletions
  " @public
  "
  " Get a simple completion list for {symbol}.
  " {symbol} should be a plain string containing a (partial) symbol name.
  function! nvlime#SimpleCompletions(symbol, Callback = v:null) dict
    let cur_package = self.GetCurrentPackage()
    if cur_package isnot v:null
      let cur_package = cur_package[0]
    endif
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'SIMPLE-COMPLETIONS'), a:symbol, cur_package]),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#SimpleCompletions']))
  endfunction

  function! nvlime#ReturnString(thread, ttag, str) dict
    call self.Send([s:KW('EMACS-RETURN-STRING'), a:thread, a:ttag, a:str])
  endfunction

  function! nvlime#Return(thread, ttag, val) dict
    call self.Send([s:KW('EMACS-RETURN'), a:thread, a:ttag, a:val])
  endfunction

  ""
  " @dict NvlimeConnection.SwankMacroExpandOne
  " @public
  "
  " Perform one macro expansion on {expr}.
  " {expr} should be a plain string containing the lisp expression to be
  " expanded.
  function! nvlime#SwankMacroExpandOne(expr, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'SWANK-MACROEXPAND-1'), a:expr]),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#SwankMacroExpandOne']))
  endfunction

  ""
  " @dict NvlimeConnection.SwankMacroExpand
  " @public
  "
  " Expand {expr}, until the resulting form cannot be macro-expanded anymore.
  function! nvlime#SwankMacroExpand(expr, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'SWANK-MACROEXPAND'), a:expr]),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#SwankMacroExpand']))
  endfunction

  ""
  " @dict NvlimeConnection.SwankMacroExpandAll
  " @public
  "
  " Recursively expand all macros in {expr}.
  function! nvlime#SwankMacroExpandAll(expr, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'SWANK-MACROEXPAND-ALL'), a:expr]),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#SwankMacroExpandAll']))
  endfunction

  ""
  " @dict NvlimeConnection.DisassembleForm
  " @public
  "
  " Compile and disassemble {expr}.
  function! nvlime#DisassembleForm(expr, Callback = v:null) dict
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'DISASSEMBLE-FORM'), a:expr]),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#DisassembleForm']))
  endfunction

  ""
  " @dict NvlimeConnection.CompileStringForEmacs
  " @public
  "
  " Compile {expr}.
  " {buffer}, {position} and {filename} specify where {expr} is from. When
  " {buffer} or {filename} is unknown, one can pass v:null instead.
  " [policy] should be a dictionary specifying a compiler policy. For example,
  "
  "     {"DEBUG": 3, "SPEED": 0}
  "
  " This means no optimization in runtime speed, and maximum debug info.
  function! nvlime#CompileStringForEmacs(expr, buffer, position, filename, policy = v:null, Callback = v:null) dict
    let policy = s:TransformCompilerPolicy(a:policy)
    let fixed_filename = self.FixLocalPath(a:filename)
    call self.Send(self.EmacsRex(
          \ [s:SYM('SWANK', 'COMPILE-STRING-FOR-EMACS'),
          \ a:expr, a:buffer,
          \ [s:CL('QUOTE'), [[s:KW('POSITION'), a:position]]],
          \ fixed_filename, policy]),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#CompileStringForEmacs']))
  endfunction


  ""
  " @dict NvlimeConnection.CompileFileForEmacs
  " @public
  "
  " Compile a file with the name {filename}.
  " [load], if present and |TRUE|, tells Nvlime to automatically load the compiled
  " file after successful compilation.
  " [policy] is the compiler policy, see
  " @function(NvlimeConnection.CompileStringForEmacs).
  function! nvlime#CompileFileForEmacs(filename, load = v:true, policy = v:null, Callback = v:null) dict
    let policy = s:TransformCompilerPolicy(a:policy)
    let fixed_filename = self.FixLocalPath(a:filename)
    let cmd = [s:SYM('SWANK', 'COMPILE-FILE-FOR-EMACS'), fixed_filename, a:load]
    if policy isnot v:null
      let cmd += [s:KW('POLICY'), policy]
    endif
    call self.Send(self.EmacsRex(cmd),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#CompileFileForEmacs']))
  endfunction

  ""
  " @dict NvlimeConnection.LoadFile
  " @public
  "
  " Load a file with the name {filename}.
  function! nvlime#LoadFile(filename, Callback = v:null) dict
    let fixed_filename = self.FixLocalPath(a:filename)
    call self.Send(self.EmacsRex([s:SYM('SWANK', 'LOAD-FILE'), fixed_filename]),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#LoadFile']))
  endfunction

  ""
  " @dict NvlimeConnection.XRef
  " @public
  "
  " Cross reference lookup.
  " {ref_type} can be "CALLS", "CALLS-WHO", "REFERENCES", "BINDS", "SETS",
  " "MACROEXPANDS", or "SPECIALIZES".
  " {name} is the symbol name to lookup.
  function! nvlime#XRef(ref_type, name, Callback = v:null) dict
    function! s:XRefCB(conn, Cb, chan, msg)
      call s:CheckReturnStatus(a:msg,  'nvlime#XRef')
      call s:FixXRefListPaths(a:conn, a:msg[1][1])
      call s:TryToCall(a:Cb, [a:conn, a:msg[1][1]])
    endfunction

    call self.Send(self.EmacsRex([s:SYM('SWANK', 'XREF'), s:KW(a:ref_type), a:name]),
          \ function('s:XRefCB', [self, a:Callback]))
  endfunction

  ""
  " @dict NvlimeConnection.FindDefinitionsForEmacs
  " @public
  "
  " Lookup definitions for symbol {name}.
  function! nvlime#FindDefinitionsForEmacs(name, Callback = v:null) dict
    function! s:FindDefinitionsForEmacsCB(conn, Cb, chan, msg)
      call s:CheckReturnStatus(a:msg, 'nvlime#FindDefinitionsForEmacs')
      call s:FixXRefListPaths(a:conn, a:msg[1][1])
      call s:TryToCall(a:Cb, [a:conn, a:msg[1][1]])
    endfunction

    call self.Send(self.EmacsRex([s:SYM('SWANK', 'FIND-DEFINITIONS-FOR-EMACS'), a:name]),
          \ function('s:FindDefinitionsForEmacsCB', [self, a:Callback]))
  endfunction

  ""
  " @dict NvlimeConnection.FindSourceLocationForEmacs
  " @public
  "
  " Lookup source locations for certain objects.
  " {spec} specifies what to look for. When {spec} is ['STRING', <expr>,
  " <package>], evaluate <expr> in <package>, and then find the source for the
  " resulting object. When {spec} is ['INSPECTOR', <part_id>], find the source
  " for the object shown in the inspector with <part_id>. When {spec} is
  " ['SLDB', <frame>, <nth>], find the source for the <nth> local variable in
  " <frame> in the debugger.
  function! nvlime#FindSourceLocationForEmacs(spec, Callback = v:null) dict
    function! s:FindSourceLocationForEmacsCB(conn, Cb, chan, msg)
      call s:CheckReturnStatus(a:msg, 'nvlime#FindSourceLocationForEmacs')
      if a:msg[1][1] isnot v:null && a:msg[1][1][0]['name'] == 'LOCATION'
        let fixed_loc = a:conn.FixRemotePath(a:msg[1][1])
      else
        let fixed_loc = a:msg[1][1]
      endif
      call s:TryToCall(a:Cb, [a:conn, fixed_loc])
    endfunction

    let spec_type = a:spec[0]
    let spec = [s:CL('QUOTE'), [s:KW(spec_type)] + a:spec[1:]]

    call self.Send(self.EmacsRex([s:SYM('SWANK', 'FIND-SOURCE-LOCATION-FOR-EMACS'), spec]),
          \ function('s:FindSourceLocationForEmacsCB', [self, a:Callback]))
  endfunction

  ""
  " @dict NvlimeConnection.AproposListForEmacs
  " @public
  "
  " Lookup symbol names containing {name}.
  " If {external_only} is |TRUE|, only return external symbols.
  " {case_sensitive} specifies whether the search is case-sensitive or not.
  " {package} limits the search to a specific package, but one can pass v:null
  " to search all packages.
  function! nvlime#AproposListForEmacs(name, external_only, case_sensitive, package, Callback = v:null) dict
    call self.Send(self.EmacsRex([s:SYM('SWANK', 'APROPOS-LIST-FOR-EMACS'),
          \ a:name, a:external_only, a:case_sensitive, a:package]),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#AproposListForEmacs']))
  endfunction

  ""
  " @dict NvlimeConnection.DocumentationSymbol
  " @public
  "
  " Find the documentation for symbol {sym_name}.
  function! nvlime#DocumentationSymbol(sym_name, Callback = v:null) dict
    call self.Send(self.EmacsRex([s:SYM('SWANK', 'DOCUMENTATION-SYMBOL'), a:sym_name]),
          \ function('nvlime#SimpleSendCB', [self, a:Callback, 'nvlime#DocumentationSymbol']))
  endfunction

  " ------------------ server event handlers ------------------

  function! nvlime#OnPing(conn, msg)
    let [_msg_type, thread, ttag] = a:msg
    call a:conn.Pong(thread, ttag)
  endfunction

  function! nvlime#OnNewPackage(conn, msg)
    call a:conn.SetCurrentPackage([a:msg[1], a:msg[2]])
  endfunction

  function! nvlime#OnDebug(conn, msg)
    if a:conn.ui isnot v:null
      let [_msg_type, thread, level, condition, restarts, frames, conts] = a:msg
      call a:conn.ui.OnDebug(a:conn, thread, level, condition, restarts, frames, conts)
    endif
  endfunction

  function! nvlime#OnDebugActivate(conn, msg)
    if a:conn.ui isnot v:null
      if len(a:msg) == 4
        let [_msg_type, thread, level, select] = a:msg
      elseif len(a:msg) == 3
        let [_msg_type, thread, level] = a:msg
        let select = v:null
      endif
      call a:conn.ui.OnDebugActivate(a:conn, thread, level, select)
    endif
  endfunction

  function! nvlime#OnDebugReturn(conn, msg)
    if a:conn.ui isnot v:null
      let [_msg_type, thread, level, stepping] = a:msg
      call a:conn.ui.OnDebugReturn(a:conn, thread, level, stepping)
    endif
  endfunction

  function! nvlime#OnWriteString(conn, msg)
    if a:conn.ui isnot v:null
      let str = a:msg[1]
      let str_type = (len(a:msg) >= 3) ? a:msg[2] : v:null
      call a:conn.ui.OnWriteString(a:conn, str, str_type)
    endif
  endfunction

  function! nvlime#OnReadString(conn, msg)
    if a:conn.ui isnot v:null
      let [_msg_type, thread, ttag] = a:msg
      call a:conn.ui.OnReadString(a:conn, thread, ttag)
    endif
  endfunction

  function! nvlime#OnReadFromMiniBuffer(conn, msg)
    if a:conn.ui isnot v:null
      let [_msg_type, thread, ttag, prompt, init_val] = a:msg
      call a:conn.ui.OnReadFromMiniBuffer(
            \ a:conn, thread, ttag, prompt, init_val)
    endif
  endfunction

  function! nvlime#OnIndentationUpdate(conn, msg)
    if a:conn.ui isnot v:null
      let [_msg_type, indent_info] = a:msg
      call a:conn.ui.OnIndentationUpdate(a:conn, indent_info)
    endif
  endfunction

  function! nvlime#OnNewFeatures(conn, msg)
    if a:conn.ui isnot v:null
      let [_msg_type, new_features] = a:msg
      call a:conn.ui.OnNewFeatures(a:conn, new_features)
    endif
  endfunction

  function! nvlime#OnInvalidRPC(conn, msg)
    if a:conn.ui isnot v:null
      let [_msg_type, id, err_msg] = a:msg
      call a:conn.ui.OnInvalidRPC(a:conn, id, err_msg)
    endif
  endfunction

  function! nvlime#OnInspect(conn, msg)
    if a:conn.ui isnot v:null
      let [_msg_type, i_content, i_thread, i_tag] = a:msg
      call a:conn.ui.OnInspect(a:conn, i_content, i_thread, i_tag)
    endif
  endfunction

  function! nvlime#OnChannelSend(conn, msg)
    let [_msg_type, chan_id, msg_body] = a:msg
    let chan_obj = get(a:conn['local_channels'], chan_id, v:null)
    if chan_obj isnot v:null
      if chan_obj['callback'] isnot v:null
        let CB = function(chan_obj['callback'],
              \ [a:conn, chan_obj, msg_body])
        call CB()
      elseif get(g:, '_nvlime_debug', v:false)
        echom 'Unhandled message: ' . string(a:msg)
      endif
    elseif get(g:, '_nvlime_debug', v:false)
      echom 'Unknown channel: ' . string(a:msg)
    endif
  endfunction

  " ------------------ end of server event handlers ------------------

  function! nvlime#OnServerEvent(chan, msg) dict
    let msg_type = a:msg[0]
    let Handler = get(self.server_event_handlers, msg_type['name'], v:null)
    if type(Handler) == v:t_func
      call Handler(self, a:msg)
    elseif get(g:, '_nvlime_debug', v:false)
      echom 'Unknown server event: ' . string(a:msg)
    endif
  endfunction

  " ================== end of methods for nvlime connections ==================

  function! nvlime#SimpleSendCB(conn, Callback, caller, chan, msg) abort
    call s:CheckReturnStatus(a:msg, a:caller)
    call s:TryToCall(a:Callback, [a:conn, a:msg[1][1]])
  endfunction

  function! s:SLDBSendCB(conn, Callback, caller, chan, msg) abort
    let status = a:msg[1][0]
    if status['name'] != 'ABORT' && status['name'] != 'OK'
      throw caller . ' returned: ' . string(a:msg[1])
    endif
    call s:TryToCall(a:Callback, [a:conn, a:msg[1][1]])
  endfunction

  ""
  " @public
  "
  " Convert a {plist} sent from the server to a native |dict|.
  function! nvlime#PListToDict(plist)
    if a:plist is v:null
      return {}
    endif

    let d = {}
    let i = 0
    while i < len(a:plist)
      let d[a:plist[i]['name']] = a:plist[i+1]
      let i += 2
    endwhile
    return d
  endfunction

  ""
  " @usage [func_and_cb...]
  " @public
  "
  " Make a chain of async calls and corresponding callbacks. For example:
  "
  "     call nvlime#ChainCallbacks(<f1>, <cb1>, <f2>, <cb2>, <f3>, <cb3>)
  "
  " <f2> will be called after <cb1> has finished, and <f3> will be called after
  " <cb2> has finished, and so on.
  function! nvlime#ChainCallbacks(...)
    let cbs = a:000
    if len(cbs) <= 0
      return
    endif

    function! s:ChainCallbackCB(cbs, ...)
      if len(a:cbs) < 1
        return
      endif
      let CB = function(a:cbs[0], a:000)
      call CB()

      if len(a:cbs) < 2
        return
      endif
      let NextFunc = a:cbs[1]
      call NextFunc(function('s:ChainCallbackCB', [a:cbs[2:]]))
    endfunction

    let FirstFunc = cbs[0]
    call FirstFunc(function('s:ChainCallbackCB', [cbs[1:]]))
  endfunction

  ""
  " @public
  "
  " Parse a source location object {loc} sent from the server, and convert it
  " into a native |dict|.
  function! nvlime#ParseSourceLocation(loc)
    if type(a:loc[0]) != v:t_dict || a:loc[0]['name'] != 'LOCATION'
      throw 'nvlime#ParseSourceLocation: invalid location: ' .. string(a:loc)
    endif

    let loc_obj = {}

    for p in a:loc[1:]
      if type(p) != v:t_list
        continue
      endif

      if len(p) == 1
        let loc_obj[p[0]['name']] = v:null
      elseif len(p) == 2
        let loc_obj[p[0]['name']] = p[1]
      elseif len(p) > 2
        let loc_obj[p[0]['name']] = p[1:]
      endif
    endfor

    return loc_obj
  endfunction

  ""
  " @public
  "
  " Normalize a source location object parsed by
  " @function(nvlime#ParseSourceLocation).
  function! nvlime#GetValidSourceLocation(loc)
    let loc_file = get(a:loc, 'FILE', v:null)
    let loc_buffer = get(a:loc, 'BUFFER', v:null)
    let loc_buf_and_file = get(a:loc, 'BUFFER-AND-FILE', v:null)
    let loc_src_form = get(a:loc, 'SOURCE-FORM', v:null)

    if loc_file isnot v:null
      let loc_pos = get(a:loc, 'POSITION', v:null)
      let loc_snippet = get(a:loc, 'SNIPPET', v:null)
      let valid_loc = [loc_file, loc_pos, loc_snippet]
    elseif loc_buffer isnot v:null
      let loc_offset = get(a:loc, 'OFFSET', v:null)
      let loc_snippet = get(a:loc, 'SNIPPET', v:null)
      if loc_offset isnot v:null
        " Negative offsets are used to designate the code snippets entered
        " via the input buffer
        if loc_offset[0] < 0 || loc_offset[1] < 0
          let loc_offset = v:null
        else
          let loc_offset = loc_offset[0] + loc_offset[1]
        endif
      endif
      let valid_loc = [loc_buffer, loc_offset, loc_snippet]
    elseif loc_buf_and_file isnot v:null
      let loc_offset = get(a:loc, 'OFFSET', v:null)
      let loc_snippet = get(a:loc, 'SNIPPET', v:null)
      if loc_offset isnot v:null
        if loc_offset[0] < 0 || loc_offset[1] < 0
          let loc_offset = v:null
        else
          let loc_offset = loc_offset[0] + loc_offset[1]
        endif
      endif
      let valid_loc = [loc_buf_and_file[0], loc_offset, loc_snippet]
    elseif loc_src_form isnot v:null
      let valid_loc = [v:null, 1, loc_src_form]
    else
      let valid_loc = []
    endif

    return valid_loc
  endfunction

  ""
  " @public
  "
  " Parse {expr} and turn it into a raw form usable by
  " @function(NvlimeConnection.Autodoc). See the source of SWANK:AUTODOC for an
  " explanation of the raw forms.
  function! nvlime#ToRawForm(expr)
    let form = []
    let paren_level = 0
    let idx = 0
    let cur_token = ''
    let delimiter = v:false
    let sub_form_complete = v:true

    while idx < len(a:expr)
      let delta = 1
      let delimiter = v:false

      let ch = a:expr[idx]
      if ch == '('
        let delimiter = v:true
        let paren_level += 1
      elseif ch == ')'
        let delimiter = v:true
        let paren_level -= 1
      elseif ch =~ '\_s'
        let delimiter = v:true
      elseif ch == '"' || ch == '|'
        try
          let [str, delta] = s:ReadRawFormString(a:expr[idx:], ch)
        catch 'ReadRawFormString:.\+'
          let str = ''
          let delta = len(a:expr) - idx
        endtry
        let cur_token .= join([ch, escape(str, ch . '\'), ch], '')
      elseif ch == '#'
        try
          let [str, delta] = s:ReadRawFormSharp(a:expr[idx:])
        catch 'ReadRawFormSharp:.\+'
          let str = ''
          let delta = len(a:expr) - idx
        endtry
        let cur_token .= str
      elseif ch == '''' || ch == '`' || ch == ','
        if idx + 1 >= len(a:expr) || a:expr[idx+1] != '('
          let cur_token .= ch
        endif
      elseif ch == '\'
        if idx + 1 < len(a:expr)
          let cur_token .= a:expr[idx:idx+1]
          let delta = 2
        else
          let delta = len(a:expr) - idx
        endif
      elseif ch == ';'
        let delimiter = v:true
        let delta = s:ReadRawFormSemiColon(a:expr[idx:])
      else
        let cur_token .= ch
      endif

      if delimiter && len(cur_token) > 0
        call add(form, cur_token)
        let cur_token = ''
      endif

      if paren_level > 1
        let [sub_form, delta, sub_form_complete] = nvlime#ToRawForm(a:expr[idx:])
        call add(form, sub_form)
        let paren_level -= 1
      elseif paren_level <= 0
        return [form, idx + 1, v:true]
      endif

      let idx += delta
    endwhile

    if sub_form_complete
      call add(form, "")
      call add(form, {'package': 'SWANK', 'name': '%CURSOR-MARKER%'})
    endif

    return [form, len(a:expr), v:false]
  endfunction

  ""
  " @usage {func} {key} {cache} [scope] [cache_limit]
  " @private
  "
  " Memoize {func} by caching it's result in a dictionary in [scope]. The result
  " will be stored under {key}. If [scope] is omitted, default to |b:|. If
  " [cache_limit] is specified, impose a limit to the cache size.
  function! nvlime#Memoize(func, key, cache, scope = b:, cache_limit = v:null)

    let cache = get(a:scope, a:cache, {})
    try
      let result = cache[a:key]
      let key_present = v:true
    catch /^Vim\%((\a\+)\)\=:E716/  " Key not present in Dictionary
      let key_present = v:false
    endtry

    if key_present
      return result
    else
      let result = a:func()
      if a:cache_limit isnot v:null && a:cache_limit > 0 && len(cache) >= a:cache_limit
        let keys = keys(cache)
        while len(keys) >= a:cache_limit
          let idx = nvlime#Rand() % len(keys)
          call remove(cache, remove(keys, idx))
        endwhile
      endif
      let cache[a:key] = result
      let a:scope[a:cache] = cache
      return result
    endif
  endfunction

  ""
  " @private
  "
  " Generate a random integer from 1 to 99999.
  function! nvlime#Rand()
    return rand() % 99998 + 1
  endfunction

  ""
  " @private
  "
  " Check the returned status of async messages. Throw an exception if the
  " request failed. An ad-hoc measure to export s:CheckReturnStatus().
  function! nvlime#CheckReturnStatus(return_msg, caller)
    return s:CheckReturnStatus(a:return_msg, a:caller)
  endfunction

  ""
  " @private
  "
  " Try to call {Callback}. If {Callback} is not a valid |Funcref|, do nothing.
  " An ad-hoc measure to export s:TryToCall().
  function! nvlime#TryToCall(Callback, args)
    call s:TryToCall(a:Callback, a:args)
  endfunction

  ""
  " @private
  "
  " Return a Common Lisp symbol serialized using the Nvlime protocol. An ad-hoc
  " measure to export s:SYM().
  function! nvlime#SYM(package, name)
    return s:SYM(a:package, a:name)
  endfunction

  ""
  " @private
  "
  " Return a Common Lisp keyword serialized using the Nvlime protocol. An ad-hoc
  " measure to export s:KW().
  function! nvlime#KW(name)
    return s:KW(a:name)
  endfunction

  ""
  " @private
  "
  " Return a Common Lisp symbol in the CL package, serialized using the Nvlime
  " protocol. An ad-hoc measure to export s:CL().
  function! nvlime#CL(name)
    return s:CL(a:name)
  endfunction

  function! s:SearchPList(plist, name)
    let i = 0
    while i < len(a:plist)
      if a:plist[i]['name'] == a:name
        return a:plist[i+1]
      endif
      let i += 2
    endwhile
  endfunction

  function! s:CheckReturnStatus(return_msg, caller)
    let status = a:return_msg[1][0]
    if status['name'] != 'OK'
      throw a:caller . ' returned: ' . string(a:return_msg[1])
    endif
  endfunction

  function! s:SYM(package, name)
    return {'name': a:name, 'package': a:package}
  endfunction

  function! s:KW(name)
    return s:SYM('KEYWORD', a:name)
  endfunction

  function! s:CL(name)
    return s:SYM('COMMON-LISP', a:name)
  endfunction

  function! s:EmacsRex(cmd, pkg, thread)
    return [s:KW('EMACS-REX'), a:cmd, a:pkg, a:thread]
  endfunction

  function! s:TryToCall(Callback, args)
    if type(a:Callback) == v:t_func
      let CB = function(a:Callback, a:args)
      call CB()
    endif
  endfunction

  function! s:FixXRefListPaths(conn, xref_list)
    if type(a:xref_list) != v:t_list
      return
    endif

    for spec in a:xref_list
      if type(spec[0]) == v:t_string && spec[1][0]['name'] == 'LOCATION'
        let spec[1] = a:conn.FixRemotePath(spec[1])
      endif
    endfor
  endfunction

  function! s:TransformCompilerPolicy(policy)
    if type(a:policy) == v:t_dict
      let plc_list = []
      for [key, val] in items(a:policy)
        call add(plc_list, {'head': [s:CL(key)], 'tail': val})
      endfor
      return [s:CL('QUOTE'), plc_list]
    else
      return a:policy
    endif
  endfunction

  function! s:ReadRawFormString(expr, mark)
    if a:expr[0] == a:mark
      let str = []
      let idx = 1
      while idx < len(a:expr)
        let ch = a:expr[idx]
        if ch == '\'
          let idx += 1
          if idx < len(a:expr)
            let ch = a:expr[idx]
          else
            throw 'ReadRawFormString: early eof'
          endif
        elseif ch == a:mark
          return [join(str, ''), idx + 1]
        endif

        call add(str, ch)
        let idx += 1
      endwhile

      throw 'ReadRawFormString: unterminated string'
    else
      return ['', 0]
    endif
  endfunction

  function! s:ReadRawFormSharp(expr)
    if a:expr[0] == '#'
      if len(a:expr) <= 1
        return [a:expr, len(a:expr)]
      elseif a:expr[1] == '('
        return ['', 1]
      elseif a:expr[1] == '\'
        if len(a:expr) < 3
          throw 'ReadRawFormSharp: early eof'
        else
          return [a:expr[0:2], 3]
        endif
      elseif a:expr[1] == '.'
        return ['', 2]
      elseif a:expr[1] =~ '\_s'
        return [a:expr[0], 1]
      else
        return [a:expr[0:1], 2]
      endif
    else
      return ['', 0]
    endif
  endfunction

  function! s:ReadRawFormSemiColon(expr)
    if a:expr[0] == ';'
      let idx = 1
      while idx < len(a:expr) && a:expr[idx] != "\n"
        let idx += 1
      endwhile
      return idx + 1
    else
      return 0
    endif
  endfunction

  function! nvlime#DummyCB(conn, result)
    echom '---------------------------'
    echom string(a:result)
  endfunction

  function! nvlime#KeywordList2Dict(input)
    if type(a:input) == v:t_list
      let dct = {}
      for el in a:input
        if type(el) == v:t_list && type(el[0]) == v:t_dict && el[0]["package"] == 'KEYWORD'
          let dct[ el[0]["name"] ] = el[1]
        endif
      endfor
      return dct
    endif
  endfunction

  function! nvlime#ClearCurrentBuffer()
    1,$delete _
  endfunction

" vim: sw=2

""
" @dict NvlimeConnection.ClearTraceTree
" @usage [callback]
" @public
"
" Clear all trace entries in SWANK-TRACE-DIALOG.
"
" This method needs the SWANK-TRACE-DIALOG contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#trace_dialog#ClearTraceTree(...) dict
  let Callback = get(a:000, 0, v:null)
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-TRACE-DIALOG', 'CLEAR-TRACE-TREE')]),
        \ function('nvlime#SimpleSendCB',
        \ [self, Callback, 'nvlime#contrib#trace_dialog#ClearTraceTree']))
endfunction

""
" @dict NvlimeConnection.DialogToggleTrace
" @usage {name} [callback]
" @public
"
" Toggle the traced state of a function in SWANK-TRACE-DIALOG. {name} can be a
" plain string specifying the function name, or "(setf <name>)" to refer to a
" SETF function. You can also pass raw JSON objects.
"
" This method needs the SWANK-TRACE-DIALOG contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#trace_dialog#DialogToggleTrace(name, ...) dict
  let Callback = get(a:000, 0, v:null)
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-TRACE-DIALOG', 'DIALOG-TOGGLE-TRACE'),
        \ s:TranslateFunctionSpec(a:name)]),
        \ function('nvlime#SimpleSendCB',
        \ [self, Callback, 'nvlime#contrib#trace_dialog#DialogToggleTrace']))
endfunction

""
" @dict NvlimeConnection.DialogTrace
" @usage {name} [callback]
" @public
"
" Trace a function in SWANK-TRACE-DIALOG. See
" @function(NvlimeConnection.DialogToggleTrace) for the use of {name}.
"
" This method needs the SWANK-TRACE-DIALOG contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#trace_dialog#DialogTrace(name, ...) dict
  let Callback = get(a:000, 0, v:null)
  let pkg = s:GetCurrentPackage(self)
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-TRACE-DIALOG', 'DIALOG-TRACE'),
        \ s:TranslateFunctionSpec(a:name)]),
        \ function('nvlime#SimpleSendCB',
        \ [self, Callback, 'nvlime#contrib#trace_dialog#DialogTrace']))
endfunction

""
" @dict NvlimeConnection.DialogUntrace
" @usage {name} [callback]
" @public
"
" Untrace a function in SWANK-TRACE-DIALOG. See
" @function(NvlimeConnection.DialogToggleTrace) for the use of {name}.
"
" This method needs the SWANK-TRACE-DIALOG contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#trace_dialog#DialogUntrace(name, ...) dict
  let Callback = get(a:000, 0, v:null)
  let pkg = s:GetCurrentPackage(self)
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-TRACE-DIALOG', 'DIALOG-UNTRACE'),
        \ s:TranslateFunctionSpec(a:name)]),
        \ function('nvlime#SimpleSendCB',
        \ [self, Callback, 'nvlime#contrib#trace_dialog#DialogUntrace']))
endfunction

""
" @dict NvlimeConnection.DialogUntraceAll
" @usage [callback]
" @public
"
" Untrace all functions in SWANK-TRACE-DIALOG.
"
" This method needs the SWANK-TRACE-DIALOG contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#trace_dialog#DialogUntraceAll(...) dict
  let Callback = get(a:000, 0, v:null)
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-TRACE-DIALOG', 'DIALOG-UNTRACE-ALL')]),
        \ function('nvlime#SimpleSendCB',
        \ [self, Callback, 'nvlime#contrib#trace_dialog#DialogUntraceAll']))
endfunction

""
" @dict NvlimeConnection.FindTrace
" @usage {id} [callback]
" @public
"
" Retrieve a trace entry by {id}.
"
" This method needs the SWANK-TRACE-DIALOG contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#trace_dialog#FindTrace(id, ...) dict
  let Callback = get(a:000, 0, v:null)
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-TRACE-DIALOG', 'FIND-TRACE'), a:id]),
        \ function('nvlime#SimpleSendCB',
        \ [self, Callback, 'nvlime#contrib#trace_dialog#FindTrace']))
endfunction

""
" @dict NvlimeConnection.FindTracePart
" @usage {id} {part_id} {type} [callback]
" @public
"
" Retrieve an argument or return value saved in a trace entry. {id} is the
" trace entry ID. {part_id} is the argument or return value ID. {type} can be
" "ARG" or "RETVAL".
"
" This method needs the SWANK-TRACE-DIALOG contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#trace_dialog#FindTracePart(id, part_id, type, ...) dict
  let Callback = get(a:000, 0, v:null)
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-TRACE-DIALOG', 'FIND-TRACE-PART'),
        \ a:id, a:part_id, nvlime#KW(a:type)]),
        \ function('nvlime#SimpleSendCB',
        \ [self, Callback, 'nvlime#contrib#trace_dialog#FindTracePart']))
endfunction

""
" @dict NvlimeConnection.InspectTracePart
" @usage {id} {part_id} {type} [callback]
" @public
"
" Inspect an argument or return value saved in a trace entry. See
" @function(NvlimeConnection.FindTracePart) for the use of the arguments.
"
" This method needs the SWANK-TRACE-DIALOG contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#trace_dialog#InspectTracePart(id, part_id, type, ...) dict
  let Callback = get(a:000, 0, v:null)
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-TRACE-DIALOG', 'INSPECT-TRACE-PART'),
        \ a:id, a:part_id, nvlime#KW(a:type)]),
        \ function('nvlime#SimpleSendCB',
        \ [self, Callback, 'nvlime#contrib#trace_dialog#InspectTracePart']))
endfunction

""
" @dict NvlimeConnection.ReportPartialTree
" @usage {key} [callback]
" @public
"
" Retrieve at most SWANK-TRACE-DIALOG:*TRACES-PER-REPORT* trace entries. {key}
" should be a uniqe number or string to identify the requesting entity.
" Subsequent requests should provide the same key.
"
" This method needs the SWANK-TRACE-DIALOG contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#trace_dialog#ReportPartialTree(key, ...) dict
  let Callback = get(a:000, 0, v:null)
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-TRACE-DIALOG', 'REPORT-PARTIAL-TREE'), a:key]),
        \ function('nvlime#SimpleSendCB',
        \ [self, Callback, 'nvlime#contrib#trace_dialog#ReportPartialTree']))
endfunction

""
" @dict NvlimeConnection.ReportSpecs
" @usage [callback]
" @public
"
" Retrieve traced function specs from SWANK-TRACE-DIALOG.
"
" This method needs the SWANK-TRACE-DIALOG contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#trace_dialog#ReportSpecs(...) dict
  let Callback = get(a:000, 0, v:null)
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-TRACE-DIALOG', 'REPORT-SPECS')]),
        \ function('nvlime#SimpleSendCB',
        \ [self, Callback, 'nvlime#contrib#trace_dialog#ReportSpecs']))
endfunction

""
" @dict NvlimeConnection.ReportTotal
" @usage [callback]
" @public
"
" Retrieve the total count of trace entries.
"
" This method needs the SWANK-TRACE-DIALOG contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#trace_dialog#ReportTotal(...) dict
  let Callback = get(a:000, 0, v:null)
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-TRACE-DIALOG', 'REPORT-TOTAL')]),
        \ function('nvlime#SimpleSendCB',
        \ [self, Callback, 'nvlime#contrib#trace_dialog#ReportTotal']))
endfunction

""
" @dict NvlimeConnection.ReportTraceDetail
" @usage {id} [callback]
" @public
"
" Retrieve the details of a trace entry by {id}.
"
" This method needs the SWANK-TRACE-DIALOG contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#trace_dialog#ReportTraceDetail(id, ...) dict
  let Callback = get(a:000, 0, v:null)
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK-TRACE-DIALOG', 'REPORT-TRACE-DETAIL'), a:id]),
        \ function('nvlime#SimpleSendCB',
        \ [self, Callback, 'nvlime#contrib#trace_dialog#ReportTraceDetail']))
endfunction

function! nvlime#contrib#trace_dialog#Init(conn)
  let a:conn['ClearTraceTree'] = function('nvlime#contrib#trace_dialog#ClearTraceTree')
  let a:conn['DialogToggleTrace'] = function('nvlime#contrib#trace_dialog#DialogToggleTrace')
  let a:conn['DialogTrace'] = function('nvlime#contrib#trace_dialog#DialogTrace')
  let a:conn['DialogUntrace'] = function('nvlime#contrib#trace_dialog#DialogUntrace')
  let a:conn['DialogUntraceAll'] = function('nvlime#contrib#trace_dialog#DialogUntraceAll')
  let a:conn['FindTrace'] = function('nvlime#contrib#trace_dialog#FindTrace')
  let a:conn['FindTracePart'] = function('nvlime#contrib#trace_dialog#FindTracePart')
  let a:conn['InspectTracePart'] = function('nvlime#contrib#trace_dialog#InspectTracePart')
  let a:conn['ReportPartialTree'] = function('nvlime#contrib#trace_dialog#ReportPartialTree')
  let a:conn['ReportSpecs'] = function('nvlime#contrib#trace_dialog#ReportSpecs')
  let a:conn['ReportTotal'] = function('nvlime#contrib#trace_dialog#ReportTotal')
  let a:conn['ReportTraceDetail'] = function('nvlime#contrib#trace_dialog#ReportTraceDetail')
endfunction

function! s:TranslateFunctionSpec(spec)
  if type(a:spec) == v:t_string
    return [nvlime#SYM('SWANK', 'FROM-STRING'), a:spec]
  else
    return a:spec
  endif
endfunction

function! s:GetCurrentPackage(conn)
  let pkg = a:conn.GetCurrentPackage()
  if pkg is v:null
    return 'COMMON-LISP-USER'
  endif
  return pkg[0]
endfunction

" vim: sw=2

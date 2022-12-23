""
" @dict NvlimeConnection.InspectPresentation
" @public
"
" Start inspecting an object saved by SWANK-PRESENTATIONS.
" {pres_id} should be a valid ID presented by PRESENTATION-START messages.
" If {reset} is |TRUE|, the inspector will be reset first.
"
" This method needs the SWANK-PRESENTATIONS contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#presentations#InspectPresentation(pres_id, reset, callback = v:null) dict
  call self.Send(self.EmacsRex([nvlime#SYM('SWANK', 'INSPECT-PRESENTATION'), a:pres_id, a:reset]),
        \ function('nvlime#SimpleSendCB',
        \ [self, a:callback, 'nvlime#contrib#presentations#InspectPresentation']))
endfunction

function! nvlime#contrib#presentations#Init(conn)
  let a:conn['InspectPresentation'] =
        \ function('nvlime#contrib#presentations#InspectPresentation')
  let a:conn['server_event_handlers']['PRESENTATION-START'] =
        \ { conn, msg ->
        \ luaeval('require"nvlime.contrib.presentations".on_start(_A[1], _A[2])',
        \ [conn, msg]) }
  let a:conn['server_event_handlers']['PRESENTATION-END'] =
        \ { conn, msg ->
        \ luaeval('require"nvlime.contrib.presentations".on_end(_A[1], _A[2])',
        \ [conn, msg]) }
  call a:conn.Send(a:conn.EmacsRex(
        \ [nvlime#SYM('SWANK', 'INIT-PRESENTATIONS')]),
        \ function('nvlime#SimpleSendCB',
        \ [a:conn, v:null, 'nvlime#contrib#presentations#Init']))
endfunction

" vim: sw=2

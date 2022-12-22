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
        \ function('s:OnPresentationStart')
  let a:conn['server_event_handlers']['PRESENTATION-END'] =
        \ function('s:OnPresentationEnd')
  call a:conn.Send(a:conn.EmacsRex(
        \ [nvlime#SYM('SWANK', 'INIT-PRESENTATIONS')]),
        \ function('nvlime#SimpleSendCB',
        \ [a:conn, v:null, 'nvlime#contrib#presentations#Init']))
endfunction

function! s:OnPresentationStart(conn, msg)
  let repl_buf = bufnr(nvlime#ui#REPLBufName(a:conn))
  if repl_buf < 0 | return | endif

  let coords = getbufvar(repl_buf, 'nvlime_repl_pending_coords', {})
  let [begin_pos, last_len] = nvlime#ui#WithBuffer(repl_buf,
        \ {-> [nvlime#ui#GetEndOfFileCoord(), len(getline('$'))]})
  if last_len > 0
    let begin_pos[1] += 1
  endif
  let c_list = get(coords, a:msg[1], [])
  call add(c_list, {
        \ 'begin': begin_pos,
        \ 'type': 'PRESENTATION',
        \ 'id': a:msg[1],
        \ })
  let coords[a:msg[1]] = c_list
  call setbufvar(repl_buf, 'nvlime_repl_pending_coords', coords)
endfunction

function! s:OnPresentationEnd(conn, msg)
  let repl_buf = bufnr(nvlime#ui#REPLBufName(a:conn))
  if repl_buf < 0 | return | endif

  let coords = getbufvar(repl_buf, 'nvlime_repl_pending_coords', {})
  let c_list = get(coords, a:msg[1], [])
  let c_pending = v:null
  let idx = 0
  for c in c_list
    if get(c, 'end', v:null) is v:null
      let c_pending = c
      break
    endif
    let idx += 1
  endfor

  if c_pending is v:null | return | endif

  let end_pos = nvlime#ui#WithBuffer(repl_buf, function('nvlime#ui#GetEndOfFileCoord'))
  let c_pending['end'] = end_pos

  call remove(c_list, idx)
  if len(c_list) <= 0
    call remove(coords, a:msg[1])
  endif

  call add(getbufvar(repl_buf, 'nvlime_repl_coords', []), c_pending)
  let match_list = nvlime#ui#WithBuffer(
        \ repl_buf, {-> nvlime#ui#MatchAddCoords('nvlime_replCoord', [c_pending])})
  let full_match_list = getbufvar(repl_buf, 'nvlime_repl_coords_match', [])
  call setbufvar(repl_buf, 'nvlime_repl_coords_match', full_match_list + match_list)
endfunction

" vim: sw=2

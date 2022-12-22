function! nvlime#ui#inspector#InspectorSelect()
  let coord = s:GetCurCoord()
  if coord is v:null | return | endif

  if coord['type'] == 'ACTION'
    call b:nvlime_conn.InspectorCallNthAction(coord['id'],
          \ {c, r -> c.ui.OnInspect(c, r, v:null, v:null)})
  elseif coord['type'] == 'VALUE'
    call b:nvlime_conn.InspectNthPart(coord['id'],
          \ {c, r -> c.ui.OnInspect(c, r, v:null, v:null)})
  elseif coord['type'] == 'RANGE'
    let range_size = b:nvlime_inspector_content_end -
          \ b:nvlime_inspector_content_start
    if coord['id'] > 0
      let next_start = b:nvlime_inspector_content_end
      let next_end = b:nvlime_inspector_content_end + range_size
      call b:nvlime_conn.InspectorRange(next_start, next_end,
            \ {c, r -> c.ui.OnInspect(c,
            \ [{'name': 'TITLE', 'package': 'KEYWORD'}, b:nvlime_inspector_title,
            \ {'name': 'CONTENT', 'package': 'KEYWORD'}, r],
            \ v:null, v:null)})
    elseif coord['id'] < 0
      let next_start = max([0, b:nvlime_inspector_content_start - range_size])
      let next_end = b:nvlime_inspector_content_start
      call b:nvlime_conn.InspectorRange(next_start, next_end,
            \ {c, r -> c.ui.OnInspect(c,
            \ [{'name': 'TITLE', 'package': 'KEYWORD'}, b:nvlime_inspector_title,
            \ {'name': 'CONTENT', 'package': 'KEYWORD'}, r],
            \ v:null, v:null)})
    else
      echom 'Fetching all inspector content, please wait...'
      let acc = {'TITLE': b:nvlime_inspector_title, 'CONTENT': [[], 0, 0, 0]}
      call b:nvlime_conn.InspectorRange(0, range_size,
            \ function('s:InspectorFetchAllCB', [acc]))
    endif
  endif
endfunction

function! nvlime#ui#inspector#SendCurValueToREPL()
  let coord = s:GetCurCoord()

  if coord is v:null || coord['type'] != 'VALUE'
    return
  endif

  call b:nvlime_conn.ui.OnWriteString(b:nvlime_conn,
        \ "--\n", {'name': 'REPL-SEP', 'package': 'KEYWORD'})
  call b:nvlime_conn.WithThread({'name': 'REPL-THREAD', 'package': 'KEYWORD'},
        \ function(b:nvlime_conn.ListenerEval,
        \ ['(nth-value 0 (swank:inspector-nth-part ' . coord['id'] . '))']))
endfunction

function! nvlime#ui#inspector#SendCurInspecteeToREPL()
  call b:nvlime_conn.ui.OnWriteString(b:nvlime_conn,
        \ "--\n", {'name': 'REPL-SEP', 'package': 'KEYWORD'})
  call b:nvlime_conn.WithThread({'name': 'REPL-THREAD', 'package': 'KEYWORD'},
        \ function(b:nvlime_conn.ListenerEval,
        \ ['(swank::istate.object swank::*istate*)']))
endfunction

function! nvlime#ui#inspector#FindSource(type, edit_cmd = 'hide edit')
  if a:type == 'inspectee'
    let id = 0
  elseif a:type == 'part'
    let coord = s:GetCurCoord()
    if coord is v:null || coord['type'] != 'VALUE'
      return
    endif
    let id = coord['id']
  endif

  call b:nvlime_conn.FindSourceLocationForEmacs(['INSPECTOR', id],
        \ function('s:FindSourceCB', [a:edit_cmd]))
endfunction

function! nvlime#ui#inspector#NextField(forward)
  if len(b:nvlime_inspector_coords) <= 0
    return
  endif

  let cur_pos = getcurpos()
  let sorted_coords = sort(copy(b:nvlime_inspector_coords),
        \ function('nvlime#ui#CoordSorter', [a:forward]))
  let next_coord = nvlime#ui#FindNextCoord(
        \ cur_pos[1:2], sorted_coords, a:forward)
  if next_coord is v:null
    let next_coord = sorted_coords[0]
  endif

  call setpos('.', [0, next_coord['begin'][0],
        \ next_coord['begin'][1], 0,
        \ next_coord['begin'][1]])
endfunction

function! nvlime#ui#inspector#InspectorPop()
  call b:nvlime_conn.InspectorPop(function('s:OnInspectorPopComplete', ['previous']))
endfunction

function! nvlime#ui#inspector#InspectorNext()
  call b:nvlime_conn.InspectorNext(function('s:OnInspectorPopComplete', ['next']))
endfunction

function! s:OnInspectorPopComplete(which, conn, result)
  if a:result is v:null
    call nvlime#ui#ErrMsg('No ' . a:which . ' object.')
  else
    call a:conn.ui.OnInspect(a:conn, a:result, v:null, v:null)
  endif
endfunction

function! s:InspectorFetchAllCB(acc, conn, result)
  if a:result[0] isnot v:null
    let a:acc['CONTENT'][0] += a:result[0]
  endif
  if a:result[1] > a:result[3]
    let range_size = a:result[3] - a:result[2]
    call a:conn.InspectorRange(a:result[3], a:result[3] + range_size,
          \ function('s:InspectorFetchAllCB', [a:acc]))
  else
    let a:acc['CONTENT'][1] = len(a:acc['CONTENT'][0])
    let a:acc['CONTENT'][3] = a:acc['CONTENT'][1]
    let full_content = [{'name': 'TITLE', 'package': 'KEYWORD'}, a:acc['TITLE'],
          \ {'name': 'CONTENT', 'package': 'KEYWORD'}, a:acc['CONTENT']]
    call a:conn.ui.OnInspect(a:conn, full_content, v:null, v:null)
    echom 'Done fetching inspector content.'
  endif
endfunction

function! s:FindSourceCB(edit_cmd, conn, msg)
  try
    let loc = nvlime#ParseSourceLocation(a:msg)
    let valid_loc = nvlime#GetValidSourceLocation(loc)
  catch
    let valid_loc = []
  endtry

  if len(valid_loc) > 0 && valid_loc[1] isnot v:null
    call nvim_win_close(0, v:true)
    call nvlime#ui#ShowSource(a:conn, valid_loc, a:edit_cmd)
  elseif a:msg isnot v:null && a:msg[0]['name'] == 'ERROR'
    call nvlime#ui#ErrMsg(a:msg[1])
  else
    call nvlime#ui#ErrMsg('No source available.')
  endif
endfunction

function! s:GetCurCoord()
  let cur_pos = getcurpos()
  let coord = v:null
  for c in b:nvlime_inspector_coords
    if nvlime#ui#MatchCoord(c, cur_pos[1], cur_pos[2])
      let coord = c
      break
    endif
  endfor
  return coord
endfunction

" vim: sw=2

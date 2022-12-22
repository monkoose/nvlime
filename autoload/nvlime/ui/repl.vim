function! nvlime#ui#repl#AppendOutput(repl_buf, str)
  call setbufvar(a:repl_buf, '&modifiable', 1)
  try
    call nvlime#ui#WithBuffer(a:repl_buf, function('nvlime#ui#AppendString', [a:str]))
  finally
    call setbufvar(a:repl_buf, '&modifiable', 0)
  endtry
endfunction

function! nvlime#ui#repl#InspectCurREPLPresentation()
  if index(b:nvlime_conn.cb_data['contribs'], 'SWANK-PRESENTATIONS') < 0
    call nvlime#ui#ErrMsg('SWANK-PRESENTATIONS is not available.')
    return
  endif

  let p_coord = s:FindCurCoord(getcurpos(), b:nvlime_repl_coords)
  if p_coord is v:null | return | endif

  if p_coord['type'] == 'PRESENTATION'
    call b:nvlime_conn.InspectPresentation(p_coord['id'], v:true,
          \ {c, r -> c.ui.OnInspect(c, r, v:null, v:null)})
  endif
endfunction

function! nvlime#ui#repl#YankCurREPLPresentation()
  let p_coord = s:FindCurCoord(getcurpos(), b:nvlime_repl_coords)
  if p_coord is v:null | return | endif

  if p_coord['type'] == 'PRESENTATION'
    call setreg('"', '(swank:lookup-presented-object ' .. p_coord['id'] .. ')')
    echom 'Presented object' p_coord['id'] 'yanked.'
  endif
endfunction

function! nvlime#ui#repl#NextField(forward)
  if empty(b:nvlime_repl_coords) | return | endif

  let cur_pos = getcurpos()[1:2]
  let [min, max] = s:BinarySearchCoord(b:nvlime_repl_coords, cur_pos[0])

  let last = len(b:nvlime_repl_coords) - 1
  let idx = 0
  if a:forward
    let idx = min >= last ? last : min + 1
  else
    let idx = max <= 0 ? 0 : max - 1
  endif

  let next_line = b:nvlime_repl_coords[idx]['begin'][0]
  call cursor(next_line, 1)
endfunction

function! s:BinarySearchCoord(coords, cur_line)
  if empty(a:coords) | return v:null | endif
  let first_line = a:coords[0]['begin'][0]
  if a:cur_line < first_line
    return [-1, -1]
  endif

  let length = len(a:coords)
  let last_line = a:coords[length - 1]['end'][0]
  if a:cur_line > last_line
    return [length, length]
  endif

  let min = 0
  let max = length
  while max - min > 1
    let i = (max + min) / 2
    if a:cur_line >= a:coords[i]['begin'][0]
      if a:cur_line <= a:coords[i]['end'][0]
        return [i, i]
      else
        let min = i
      endif
    else
      let max = i
    endif
  endwhile
  return [min, max]
endfunction

function! s:FindCurCoord(cur_pos, coords)
  for coord in a:coords
    if nvlime#ui#MatchCoord(coord, a:cur_pos[1], a:cur_pos[2])
      return coord
    endif
  endfor

  return v:null
endfunction

" vim: sw=2

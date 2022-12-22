function! nvlime#ui#threads#FillThreadsBuf(conn, thread_list)
  let field_widths = s:CalcAllFieldWidths(a:thread_list)
  let win_width = reduce(field_widths, { acc, val -> acc + val }) + 8
  let win_height = len(a:thread_list) + 1

  let lines = [s:CreateThreadField(field_widths, a:thread_list[0]),
        \ join([
        \ repeat(g:nvlime_horiz_sep, field_widths[0] + 1),
        \ repeat(g:nvlime_horiz_sep, field_widths[1]),
        \ repeat(g:nvlime_horiz_sep, field_widths[2] + 1)],
        \ '─┼─')]

  let coords = {}
  let idx = 0
  for thread in a:thread_list[1:]
    call add(lines, s:CreateThreadField(field_widths, thread))
    let coords[thread[0]] = idx
    let idx += 1
  endfor


  let [_, bufnr] = luaeval('require"nvlime.window.threads".open(_A[1], _A[2])',
        \ [lines, { 'conn-name': a:conn.cb_data.name }])
  call setbufvar(bufnr, 'nvlime_thread_coords', coords)
  call cursor(3, 1)
endfunction

function! nvlime#ui#threads#InterruptCurThread()
  let id = str2nr(getline('.'))
  if id > 0
    call b:nvlime_conn.Interrupt(id)
  endif
endfunction

function! nvlime#ui#threads#KillCurThread()
  let field = getline('.')
  let id = str2nr(field)
  if id > 0
    let thread_name = trim(split(field, g:nvlime_vert_sep)[1], ' ', 0)
    let answer = input('Kill thread "' .. thread_name .. '"? (y/n) ')
    if nvlime#ui#IsYesString(answer)
      call b:nvlime_conn.KillNthThread(b:nvlime_thread_coords[id],
            \ {c, _r -> nvlime#ui#threads#Refresh(c)})
    else
      call nvlime#ui#ErrMsg('Canceled.')
    endif
  endif
endfunction

function! nvlime#ui#threads#DebugCurThread()
  let id = str2nr(getline('.'))
  if id > 0
    call b:nvlime_conn.DebugNthThread(b:nvlime_thread_coords[id])
  endif
endfunction

function! nvlime#ui#threads#Refresh(conn = v:null, keep_cur_pos = v:true)
  if a:keep_cur_pos
    let cur_pos = getcurpos()
  else
    let cur_pos = v:null
  endif

  function! s:OnListThreadsComplete(c, result) closure
    call a:c.ui.OnThreads(a:c, a:result)
    if cur_pos isnot v:null
      call setpos('.', cur_pos)
    endif
  endfunction

  let conn = a:conn is v:null ? b:nvlime_conn : a:conn
  call conn.ListThreads(function('s:OnListThreadsComplete'))
endfunction

function! s:FindCurCoord(cur_pos, coords)
  for c in a:coords
    if nvlime#ui#MatchCoord(c, a:cur_pos[1], a:cur_pos[2])
      return c
    endif
  endfor
  return v:null
endfunction

function! s:NormalizeFieldValue(val)
  if type(a:val) == v:t_string
    return a:val
  elseif type(a:val) == v:t_dict
    " headers
    return a:val['name']
  else
    return string(a:val)
  endif
endfunction

function! s:CreateThreadField(field_widths, thread)
  let field = ''
  let idx = 0
  for column in a:thread
    let width = a:field_widths[idx]
    let n_str = s:NormalizeFieldValue(column)
    if idx > 0
      let field ..= nvlime#ui#Pad(g:nvlime_vert_sep .. ' ' .. n_str, '', width + 2)
    else
      let field ..= nvlime#ui#Pad(' ' .. n_str, '', width + 1)
    endif
    let idx += 1
  endfor
  return field
endfunction

function! s:CalcFieldWidth(field, thread_list)
  let max_width = 0
  for thread in a:thread_list
    let str_width = strdisplaywidth(s:NormalizeFieldValue(thread[a:field]))
    if str_width > max_width
      let max_width = str_width
    endif
  endfor
  return  max_width
endfunction

function! s:CalcAllFieldWidths(thread_list)
  return map(copy(a:thread_list[0]),
        \ {idx -> s:CalcFieldWidth(idx, a:thread_list)})
endfunction

" vim: sw=2

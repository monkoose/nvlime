function! nvlime#ui#xref#OpenXRefBuf(conn, xref_list)
  let [_, bufnr] = luaeval('require"nvlime.window.xref".open(_A[1], _A[2])',
        \ [a:xref_list, { 'conn-name': a:conn.cb_data.name }])
  call setbufvar(bufnr, 'nvlime_conn', a:conn)
  call setbufvar(bufnr, 'xref_list', a:xref_list)
endfunction

function! nvlime#ui#xref#OpenCurXref(edit_cmd = 'hide edit')
  let idx = float2nr(floor((line('.') + 1) / 2)) - 1
  let raw_xref_loc = b:xref_list[idx][1]
  try
    let xref_loc = nvlime#ParseSourceLocation(raw_xref_loc)
    let valid_loc = nvlime#GetValidSourceLocation(xref_loc)
  catch
    let valid_loc = []
  endtry

  call nvim_win_close(0, v:true)
  if len(valid_loc) > 0 && valid_loc[1] isnot v:null
    if type(valid_loc[0]) == v:t_string &&
          \ valid_loc[0][0:6] != 'sftp://' &&
          \ !filereadable(valid_loc[0])
      call nvlime#ui#ErrMsg('Not readable: ' .. valid_loc[0])
    else
      call nvlime#ui#ShowSource(b:nvlime_conn, valid_loc, a:edit_cmd)
    endif
  elseif raw_xref_loc isnot v:null && raw_xref_loc[0]['name'] == 'ERROR'
    call nvlime#ui#ErrMsg(raw_xref_loc[1])
  else
    call nvlime#ui#ErrMsg('No source available.')
  endif
endfunction

" vim: sw=2

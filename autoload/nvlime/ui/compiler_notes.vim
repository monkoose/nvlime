function! nvlime#ui#compiler_notes#InitCompilerNotesBuffer(conn, orig_win)
  let buf = bufnr(nvlime#ui#CompilerNotesBufName(a:conn), v:true)
  if !nvlime#ui#NvlimeBufferInitialized(buf)
    call nvlime#ui#SetNvlimeBufferOpts(buf, a:conn)
    call setbufvar(buf, '&filetype', 'nvlime_notes')
  endif
  call setbufvar(buf, 'nvlime_notes_orig_win', a:orig_win)
  return buf
endfunction

function! nvlime#ui#compiler_notes#FillCompilerNotesBuf(note_list)
  setlocal modifiable

  if a:note_list is v:null
    call nvlime#ui#ReplaceContent('No message from the compiler.')
    let b:nvlime_compiler_note_coords = []
    let b:nvlime_compiler_note_list = []
    return
  endif

  let coords = []
  let nlist = []
  call nvlime#ClearCurrentBuffer()
  let idx = 0
  let note_count = len(a:note_list)
  for note in a:note_list
    let note_dict = nvlime#PListToDict(note)
    call add(nlist, note_dict)

    let begin_pos = getcurpos()
    call nvlime#ui#AppendString(note_dict['SEVERITY']['name'] . ': ' . note_dict['MESSAGE'])
    let eof_coord = nvlime#ui#GetEndOfFileCoord()
    if idx < note_count - 1
      call nvlime#ui#AppendString("\n--\n")
    endif
    call add(coords, {
          \ 'begin': [begin_pos[1], begin_pos[2]],
          \ 'end': eof_coord,
          \ 'type': 'NOTE',
          \ 'id': idx,
          \ })
    let idx += 1
  endfor
  call setpos('.', [0, 1, 1, 0, 1])

  setlocal nomodifiable

  let b:nvlime_compiler_note_coords = coords
  let b:nvlime_compiler_note_list = nlist
endfunction

function! nvlime#ui#compiler_notes#OpenCurNote(edit_cmd = 'hide edit')
  let cur_pos = getcurpos()
  let note_coord = v:null
  for c in b:nvlime_compiler_note_coords
    if nvlime#ui#MatchCoord(c, cur_pos[1], cur_pos[2])
      let note_coord = c
      break
    endif
  endfor

  if note_coord is v:null
    return
  endif

  let raw_note_loc = nvlime#Get(b:nvlime_compiler_note_list[note_coord['id']], 'LOCATION')
  try
    let note_loc = nvlime#ParseSourceLocation(raw_note_loc)
    let valid_loc = nvlime#GetValidSourceLocation(note_loc)
  catch
    let valid_loc = []
  endtry

  if len(valid_loc) > 0 && valid_loc[1] isnot v:null
    let orig_win = getbufvar('%', 'nvlime_notes_orig_win', v:null)
    let [win_to_go, count_specified] = nvlime#ui#ChooseWindowWithCount(orig_win)
    if win_to_go > 0
      call win_gotoid(win_to_go)
    elseif count_specified
      return
    endif
    call nvlime#ui#ShowSource(b:nvlime_conn, valid_loc, a:edit_cmd, count_specified)
  elseif raw_note_loc isnot v:null && raw_note_loc[0]['name'] == 'ERROR'
    call nvlime#ui#ErrMsg(raw_note_loc[1])
  else
    call nvlime#ui#ErrMsg('No source available.')
  endif
endfunction

" vim: sw=2

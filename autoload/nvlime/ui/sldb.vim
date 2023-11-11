" Operates on current buffer. Should be called with nvlime#ui#WithBuffer(...)
function! nvlime#ui#sldb#FillSLDBBuf(thread, level, condition, restarts, frames)
  setlocal modifiable

  call nvlime#ClearCurrentBuffer()

  call nvlime#ui#AppendString(
        \ 'Thread: ' . a:thread . '; Level: ' . a:level . "\n\n")

  let condition_str = ''
  for c in a:condition
    if type(c) == v:t_string
      let condition_str .= (c . "\n")
    endif
  endfor
  let condition_str .= "\n"
  call nvlime#ui#AppendString(condition_str)

  let restarts_str = "Restarts:\n"
  let [max_name_len, has_star] = s:FindMaxRestartNameLen(a:restarts)
  let max_digits = len(string(len(a:restarts) - 1))
  let ri = 0
  while ri < len(a:restarts)
    let r = a:restarts[ri]
    let idx_str = nvlime#ui#Pad(string(ri), '.', max_digits)
    let restart_line = s:FormatRestartLine(r, max_name_len, has_star)
    let restarts_str .= ('  R ' . idx_str . restart_line . "\n")
    let ri += 1
  endwhile
  let restarts_str .= "\n"
  call nvlime#ui#AppendString(restarts_str)

  let frames_str = "Frames:\n"
  let max_digits = len(string(len(a:frames) - 1))
  for f in a:frames
    let idx_str = nvlime#ui#Pad(string(f[0]), '.', max_digits)
    let frames_str .= ('  F ' . idx_str . f[1] . "\n")
  endfor
  call nvlime#ui#AppendString(frames_str)

  setlocal nomodifiable
endfunction

function! nvlime#ui#sldb#ChooseCurRestart()
  let nth = s:MatchRestart()
  if nth >= 0
    call b:nvlime_conn.InvokeNthRestartForEmacs(b:nvlime_sldb_level, nth)
    return
  endif

  let frame = nvlime#ui#sldb#ShowFrameDetails()
  if frame > 0
    return
  endif

  let [fn, pos] = s:MatchFile()
  if len(fn) > 0
    call nvlime#ui#sldb#OpenFrameSource()
  endif
endfunction

function! nvlime#ui#sldb#ShowFrameDetails()
  let nth = s:MatchFrame()
  if nth < 0
    return -1
  endif
  let line = line('.')

  let frame_line_pattern = '^\s*F \d\+\|^\%$'
  if match(getline(line + 1), frame_line_pattern) != -1
    let frame = b:nvlime_sldb_frames[nth]
    let restartable = s:FrameRestartable(frame)

    call nvlime#ChainCallbacks(
          \ function(b:nvlime_conn.FrameLocalsAndCatchTags, [nth]),
          \ function('s:ShowFrameLocalsCB', [nth, restartable, line]))
  else
    let next_frame_line = search(frame_line_pattern, 'nW')
    if next_frame_line
      setlocal modifiable
      call deletebufline(bufnr(), line + 1, next_frame_line - 1)
      setlocal nomodifiable
    endif
  endif
  return 1
endfunction

function! nvlime#ui#sldb#OpenFrameSource(edit_cmd = 'hide edit')
  let nth = s:MatchFrame(v:true)
  if nth < 0
    let nth = 0
  endif

  let [win_to_go, count_specified] = nvlime#ui#ChooseWindowWithCount(v:null)
  if win_to_go <= 0 && count_specified
    return
  endif

  call b:nvlime_conn.FrameSourceLocation(nth,
        \ function('s:OpenFrameSourceCB', [a:edit_cmd, win_to_go, count_specified]))
endfunction

function! nvlime#ui#sldb#FindSource(edit_cmd = 'hide edit')
  let nth = s:MatchFrame()
  if nth < 0
    let nth = 0
  endif

  let [win_to_go, count_specified] = nvlime#ui#ChooseWindowWithCount(v:null)
  if win_to_go <= 0 && count_specified
    return
  endif

  call b:nvlime_conn.FrameLocalsAndCatchTags(nth,
        \ function('s:FindSourceCB',
        \ [a:edit_cmd, win_to_go, count_specified, nth]))
endfunction

function! nvlime#ui#sldb#RestartCurFrame()
  let nth = s:MatchFrame()
  if nth >= 0 && nth < len(b:nvlime_sldb_frames)
    let frame = b:nvlime_sldb_frames[nth]
    if s:FrameRestartable(frame)
      call b:nvlime_conn.RestartFrame(nth)
    else
      call nvlime#ui#ErrMsg('Frame ' . nth . ' is not restartable.')
    endif
  endif
endfunction

function! nvlime#ui#sldb#StepCurOrLastFrame(opr)
  let nth = s:MatchFrame()
  if nth < 0
    let nth = 0
  endif

  if a:opr == 'step'
    call b:nvlime_conn.SLDBStep(nth)
  elseif a:opr == 'next'
    call b:nvlime_conn.SLDBNext(nth)
  elseif a:opr == 'out'
    call b:nvlime_conn.SLDBOut(nth)
  endif
endfunction

function! nvlime#ui#sldb#InspectCurCondition()
  call b:nvlime_conn.InspectCurrentCondition(
        \ {c, r -> c.ui.OnInspect(c, r, v:null, v:null)})
endfunction

function! nvlime#ui#sldb#InspectVarInCurFrame()
  let varname = s:MatchVarName()
  let nth = s:MatchFrame(v:true)
  if nth < 0
    return
  endif

  let thread = b:nvlime_conn.GetCurrentThread()
  let var_num = s:MatchVarIndex() 
  if len(varname) > 0 && var_num >= 0
    call b:nvlime_conn.WithThread(thread,
          \ function(b:nvlime_conn.InspectFrameVar,
          \ [var_num, nth,
          \ {c, r -> c.ui.OnInspect(c, r, v:null, v:null)}]))
  else
    call nvlime#ui#input#FromBuffer(
          \ b:nvlime_conn, 'Inspect in frame (evaluated):',
          \ v:null,
          \ function('s:InspectInCurFrameInputComplete',
          \ [nth, thread]))
  endif
endfunction

function! s:InspectInCurFrameInputComplete(frame, thread)
  let content = nvlime#ui#CurBufferContent()
  if len(content) > 0
    call b:nvlime_conn.WithThread(a:thread,
          \ function(b:nvlime_conn.InspectInFrame,
          \ [content, a:frame,
          \ {c, r -> c.ui.OnInspect(c, r, v:null, v:null)}]))
  else
    call nvlime#ui#ErrMsg('Canceled.')
  endif
endfunction

function! nvlime#ui#sldb#EvalStringInCurFrame()
  let nth = s:MatchFrame()
  if nth < 0
    let nth = 0
  endif

  let thread = b:nvlime_conn.GetCurrentThread()
  call nvlime#ui#input#FromBuffer(
        \ b:nvlime_conn, 'Eval in frame:',
        \ v:null,
        \ function('s:EvalStringInCurFrameInputComplete',
        \ [nth, thread, b:nvlime_conn.GetCurrentPackage()[0]]))
endfunction

function! s:EvalStringInCurFrameInputComplete(frame, thread, package)
  let content = nvlime#ui#CurBufferContent()
  if len(content) > 0
    call b:nvlime_conn.WithThread(a:thread,
          \ function(b:nvlime_conn.EvalStringInFrame,
          \ [content, a:frame, a:package,
          \ {c, r -> c.ui.OnWriteString(c, r . "\n",
          \ {'name': 'FRAME-EVAL-RESULT', 'package': 'KEYWORD'})}]))
  else
    call nvlime#ui#ErrMsg('Canceled.')
  endif
endfunction

function! nvlime#ui#sldb#SendValueInCurFrameToREPL()
  let nth = s:MatchFrame()
  if nth < 0
    let nth = 0
  endif

  let thread = b:nvlime_conn.GetCurrentThread()
  call nvlime#ui#input#FromBuffer(
        \ b:nvlime_conn, 'Eval in frame and send result to REPL:',
        \ v:null,
        \ function('s:SendValueInCurFrameToREPLInputComplete',
        \ [nth, thread, b:nvlime_conn.GetCurrentPackage()[0]]))
endfunction

function! s:SendValueInCurFrameToREPLInputComplete(frame, thread, package)
  let content = nvlime#ui#CurBufferContent()
  if len(content) > 0
    call b:nvlime_conn.WithThread(a:thread,
          \ function(b:nvlime_conn.EvalStringInFrame,
          \ ['(setf cl-user::* #.(read-from-string "' . escape(content, '"') . '"))',
          \ a:frame, a:package,
          \ {c, r ->
          \ c.WithThread({'name': 'REPL-THREAD', 'package': 'KEYWORD'},
          \ function(c.ListenerEval, ['cl-user::*']))}]))
  else
    call nvlime#ui#ErrMsg('Canceled.')
  endif
endfunction

function! nvlime#ui#sldb#DisassembleCurFrame()
  let nth = s:MatchFrame()
  if nth < 0
    let nth = 0
  endif

  let thread = b:nvlime_conn.GetCurrentThread()
  call b:nvlime_conn.WithThread(thread,
        \ function(b:nvlime_conn.SLDBDisassemble,
        \ [nth, {c, r -> luaeval('require"nvlime.window.disassembly".open(_A)', r)}]))
endfunction

function! nvlime#ui#sldb#ReturnFromCurFrame()
  let nth = s:MatchFrame()
  if nth < 0
    let nth = 0
  endif

  let thread = b:nvlime_conn.GetCurrentThread()
  call nvlime#ui#input#FromBuffer(
        \ b:nvlime_conn, 'Return from frame (evaluated):',
        \ v:null,
        \ function('s:ReturnFromCurFrameInputComplete',
        \ [nth, thread]))
endfunction

function! s:ReturnFromCurFrameInputComplete(frame, thread)
  let content = nvlime#ui#CurBufferContent()
  if len(content) > 0
    call b:nvlime_conn.WithThread(a:thread,
          \ function(b:nvlime_conn.SLDBReturnFromFrame,
          \ [a:frame, content]))
  else
    call nvlime#ui#ErrMsg('Canceled.')
  endif
endfunction

function! s:FindMaxRestartNameLen(restarts)
  let max_name_len = 0
  let has_star = v:false
  for r in a:restarts
    if r[0][0] == '*'
      let start = 1
      let has_star = v:true
    else
      let start = 0
    endif
    if len(r[0][start:]) > max_name_len
      let max_name_len = len(r[0][start:])
    endif
  endfor
  return [max_name_len, has_star]
endfunction

function! s:FormatRestartLine(r, max_name_len, has_star)
  if a:has_star
    if a:r[0][0] == '*'
      let spc = ''
      let start = 1
    else
      let spc = ' '
      let start = 0
    endif
  else
    let spc = ''
    let start = 0
  endif
  let pad = repeat(' ', a:max_name_len + 1 - len(a:r[0][start:]))
  return spc . a:r[0] . pad . '- ' . a:r[1]
endfunction

function! s:MatchVarIndex()
  let loc = search('\v^\tLocals:$', 'bnWz')
  let this = line('.')
  return this - loc - 1
endfunction

function! s:MatchVarName()
  let line = getline('.')
  let matches = matchlist(line, '\v^\t  ([^ ]+):\s+')
  return (len(matches) > 0) ? matches[1] : ""
endfunction

function! s:MatchFile()
  let line = getline('.')
  let matches = matchlist(line, '\v^\tFile:\s+(.*) ([0-9]+)$')
  return (len(matches) > 0) ? matches[1:2] : [0, 0]
endfunction

function! s:MatchRestart()
  let line = getline('.')
  let matches = matchlist(line,
        \ '\v^  R\s+([0-9]+)\.\s+\*?[a-zA-Z\-]+\s+-\s.+$')
  return (len(matches) > 0) ? (matches[1] + 0) : -1
endfunction

function! s:MatchFrame_string(line)
  let matches = matchlist(a:line, '\v^  F\s+([0-9]+)\.\s')
  return (len(matches) > 0) ? (matches[1] + 0) : -1
endfunction

function! s:MatchFrame(...)
  let srchBackwards = get(a:000, 0, v:false)

  let line = getline('.')
  let fnd = s:MatchFrame_string(line)
  if (fnd > 0) || (! srchBackwards)
    return fnd
  endif

  " First line with no tab in front
  let lnr = search('\v^[^\t]', 'bnWz')
  if lnr == 0
    return -1
  endif

  let line = getline(lnr)
  return s:MatchFrame_string(line)
endfunction

function! s:ShowFrameLocalsCB(frame, restartable, line, conn, result)

  let content = "\n"

  let locals = a:result[0]
  if locals isnot v:null
    let content .= "\tLocals:\n"
    let rlocals = []
    let max_name_len = 0
    for lc in locals
      let rlc = nvlime#PListToDict(lc)
      call add(rlocals, rlc)
      let rlc_l = len(nvlime#Get(rlc, 'NAME'))
      if rlc_l > max_name_len
        let max_name_len = rlc_l
      endif
    endfor
    for rlc in rlocals
      let content ..= "\t  "     " Indentation
      let content ..= nvlime#ui#Pad(nvlime#Get(rlc, 'NAME'), ':', max_name_len)
      let content ..= (nvlime#Get(rlc, 'VALUE') .. "\n")
    endfor
  endif
  let catch_tags = a:result[1]
  if catch_tags isnot v:null
    let content ..= "\tCatch tags:\n"
    for ct in catch_tags
      let content ..= "\t  " .. ct .. "\n"
    endfor
  endif
  let thread = b:nvlime_conn.GetCurrentThread()
  "call b:nvlime_conn.WithThread(thread, {-> ???
  let buf = bufnr(nvlime#ui#SLDBBufName(a:conn, thread), v:false)
  setlocal modifiable
  call nvlime#ui#WithBuffer(buf,
        \ {-> nvlime#ui#AppendString(content, a:line) })
  setlocal nomodifiable
endfunction

function! s:ShowFrameSourceLocationCB(frame, line, conn, result)
  if a:result[0]['name'] != 'LOCATION'
    call nvlime#ui#ErrMsg(a:result[1])
    return
  endif
  let snippet = ""
  let content = ""

  if type(a:result[1]) == v:t_list
    let r = nvlime#KeywordList2Dict(a:result[1:])

    if nvlime#HasKey(r, 'SNIPPET')
      let snippet = nvlime#Get(r, 'SNIPPET')
    endif
    if nvlime#HasKey(r, 'SOURCE-FORM')
      let snippet = nvlime#Get(r, 'SOURCE-FORM')
    endif

    if nvlime#HasKey(r, 'FILE') && nvlime#HasKey(r, 'POSITION')
      " The position is likely the byte position, so not actually useful for gF
      let content = "\n\tFile: " .. nvlime#Get(r, "FILE") .. " " .. nvlime#Get(r, "POSITION") .. "\n"
    endif
  else
    let content = "\n\tPosition: " .. a:result[1] .. "\n"
    let snippet = v:null
  endif

  if snippet isnot v:null
    let snippet_lines = split(snippet, "\n")
    let snippet = join(map(snippet_lines, '"\t  " .. v:val'), "\n")
    let content ..= "\n\tSnippet:\n" .. snippet .. "\n"
  endif

  let thread = b:nvlime_conn.GetCurrentThread()
  let buf = bufnr(nvlime#ui#SLDBBufName(a:conn, thread), v:false)
  setlocal modifiable
  call nvlime#ui#WithBuffer(buf,
        \ {-> nvlime#ui#AppendString(content, a:line) })
  setlocal nomodifiable
endfunction

function! s:OpenFrameSourceCB(edit_cmd, win_to_go, force_open, conn, result)
  try
    let src_loc = nvlime#ParseSourceLocation(a:result)
    let valid_loc = nvlime#GetValidSourceLocation(src_loc)
  catch
    let valid_loc = []
  endtry

  if len(valid_loc) > 0 && valid_loc[1] isnot v:null
    if a:win_to_go > 0
      if win_id2win(a:win_to_go) <= 0
        return
      endif
      call win_gotoid(a:win_to_go)
    endif

    call nvlime#ui#ShowSource(a:conn, valid_loc, a:edit_cmd, a:force_open)
  elseif a:result isnot v:null && a:result[0]['name'] == 'ERROR'
    call nvlime#ui#ErrMsg(a:result[1])
  else
    call nvlime#ui#ErrMsg('No source available.')
  endif
endfunction

function! s:FindSourceCB(edit_cmd, win_to_go, force_open, frame, conn, msg)
  let locals = a:msg[0]
  if locals is v:null
    call nvlime#ui#ErrMsg('No local variable.')
    return
  endif

  let options = map(copy(locals),
        \ {idx, lc ->
        \ string(idx + 1) .. '. ' .. nvlime#Get(nvlime#PListToDict(lc), 'NAME')})
  echohl Question
  echom 'Which variable?'
  echohl None
  let nth_var = inputlist(options)

  if nth_var > 0
    call a:conn.FindSourceLocationForEmacs(['SLDB', a:frame, nth_var - 1],
          \ function('s:OpenFrameSourceCB',
          \ [a:edit_cmd, a:win_to_go, a:force_open]))
  else
    call nvlime#ui#ErrMsg('Canceled.')
  endif
endfunction

function! s:FrameRestartable(frame)
  if len(a:frame) > 2
    let flags = nvlime#PListToDict(a:frame[2])
    return nvlime#Get(flags, 'RESTARTABLE', v:false)
  endif
  return v:false
endfunction

" vim: sw=2

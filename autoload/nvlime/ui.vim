let g:nvlime_horiz_sep = '─'
let g:nvlime_vert_sep = '│'

" Default is {'pos': 'botright', 'size': 0, 'vertical': v:false}
let g:nvlime_default_window_settings = {
      \ 'mrepl': {'pos': 'botright', 'size': 0, 'vertical': v:false},
      \ 'trace': {'pos': 'botright', 'size': 0, 'vertical': v:false},
      \ }

""
" @dict NvlimeUI
" The @dict(NvlimeUI) object is a singleton. It's meant to be injected into
" @dict(NvlimeConnection) objects, to grant them access to the user interface.
" See @function(nvlime#New).
"

""
" @public
"
" Create a @dict(NvlimeUI) object. One should probably use
" @function(nvlime#ui#GetUI) instead.
function! nvlime#ui#New()
  let obj = {
        \ 'buffer_package_map': {},
        \ 'buffer_thread_map': {},
        \ 'GetCurrentPackage': function('nvlime#ui#GetCurrentPackage'),
        \ 'SetCurrentPackage': function('nvlime#ui#SetCurrentPackage'),
        \ 'GetCurrentThread': function('nvlime#ui#GetCurrentThread'),
        \ 'SetCurrentThread': function('nvlime#ui#SetCurrentThread'),
        \ 'OnDebug': function('nvlime#ui#OnDebug'),
        \ 'OnDebugActivate': function('nvlime#ui#OnDebugActivate'),
        \ 'OnDebugReturn': function('nvlime#ui#OnDebugReturn'),
        \ 'OnWriteString': function('nvlime#ui#OnWriteString'),
        \ 'OnReadString': function('nvlime#ui#OnReadString'),
        \ 'OnReadFromMiniBuffer': function('nvlime#ui#OnReadFromMiniBuffer'),
        \ 'OnIndentationUpdate': function('nvlime#ui#OnIndentationUpdate'),
        \ 'OnNewFeatures': function('nvlime#ui#OnNewFeatures'),
        \ 'OnInvalidRPC': function('nvlime#ui#OnInvalidRPC'),
        \ 'OnInspect': function('nvlime#ui#OnInspect'),
        \ 'OnTraceDialog': function('nvlime#ui#OnTraceDialog'),
        \ 'OnXRef': function('nvlime#ui#OnXRef'),
        \ 'OnCompilerNotes': function('nvlime#ui#OnCompilerNotes'),
        \ 'OnThreads': function('nvlime#ui#OnThreads'),
        \ }
  return obj
endfunction

""
" @public
"
" Return the UI singleton.
function! nvlime#ui#GetUI()
  if !exists('g:nvlime_ui')
    let g:nvlime_ui = nvlime#ui#New()
  endif
  return g:nvlime_ui
endfunction

""
" @dict NvlimeUI.GetCurrentPackage
" @usage [buffer]
" @public
"
" Return the Common Lisp package bound to the specified [buffer]. If no
" package is bound yet, try to guess one by looking into the buffer content.
" [buffer], if specified, should be an expression as described in |bufname()|.
" When [buffer] is omitted, work on the current buffer.
"
" The returned value is a list of two strings. The first string is the full
" name of the package, and the second string is one of the package's
" nicknames.
function! nvlime#ui#GetCurrentPackage(buf = '%') dict
  let cur_buf = bufnr(a:buf)
  let buf_pkg = get(self.buffer_package_map, cur_buf, v:null)
  if type(buf_pkg) != v:t_list
    let in_pkg = nvlime#ui#WithBuffer(cur_buf, function('nvlime#ui#CurInPackage'))
    if len(in_pkg) > 0
      let buf_pkg = [in_pkg, in_pkg]
    else
      let buf_pkg = ['COMMON-LISP-USER', 'CL-USER']
    endif
  endif
  return buf_pkg
endfunction

""
" @dict NvlimeUI.SetCurrentPackage
" @usage {pkg} [buffer]
" @public
"
" Bind a Common Lisp package {pkg} to the specified [buffer].
" {pkg} should be a list of two strings, i.e. in the same format as the return
" value of @function(NvlimeUI.GetCurrentPackage).
" See @function(NvlimeUI.GetCurrentPackage) for the use of [buffer].
"
" Note that this method doesn't check the validity of {pkg}.
function! nvlime#ui#SetCurrentPackage(pkg, buf = '%') dict
  let self.buffer_package_map[bufnr(a:buf)] = a:pkg
endfunction

""
" @dict NvlimeUI.GetCurrentThread
" @usage [buffer]
" @public
"
" Return the thread bound to [buffer]. See @function(NvlimeUI.GetCurrentPackage)
" for the use of [buffer].
"
" Currently, this method only makes sense in the debugger buffer.
function! nvlime#ui#GetCurrentThread(buf = '%') dict
  return get(self.buffer_thread_map, bufnr(a:buf), v:true)
endfunction

""
" @dict NvlimeUI.SetCurrentThread
" @usage {thread} [buffer]
" @public
"
" Bind a thread to [buffer]. See @function(NvlimeUI.GetCurrentPackage) for the
" use of [buffer].
function! nvlime#ui#SetCurrentThread(thread, buf = '%') dict
  let self.buffer_thread_map[bufnr(a:buf)] = a:thread
endfunction

function! nvlime#ui#OnDebug(conn, thread, level, condition, restarts, frames, conts) dict
  let [_, bufnr] = luaeval('require"nvlime.window.main.sldb".open(_A[1], _A[2])',
        \ [[], { 'conn-name': a:conn.cb_data.name, 'thread': a:thread,
               \ 'frames': a:frames, 'level': a:level }])
  call nvlime#ui#WithBuffer(
        \ bufnr,
        \ function('nvlime#ui#sldb#FillSLDBBuf',
        \ [a:thread, a:level, a:condition, a:restarts, a:frames]))
endfunction

function! nvlime#ui#OnDebugActivate(conn, thread, level, select) dict
  let [_, bufnr] = luaeval('require"nvlime.window.main.sldb".open(_A[1], _A[2])',
        \ [[], { 'conn-name': a:conn.cb_data.name, 'thread': a:thread }])
  if bufnr > 0
    call cursor([1, 1, 0, 1])
  endif
endfunction

function! nvlime#ui#OnDebugReturn(conn, thread, level, stepping) dict
  call luaeval('require"nvlime.window.main.sldb"["on-debug-return"](_A)',
        \ { 'conn-name': a:conn.cb_data.name, 'thread': a:thread,
        \ 'level': a:level })
endfunction

""
" @public
"
" Write an arbitrary string {str} to the REPL buffer.
" {conn} should be a valid @dict(NvlimeConnection). {str_type} is currently
" ignored.
function! nvlime#ui#OnWriteString(conn, str, str_type) dict
  let [_, bufnr] = luaeval('require"nvlime.window.main.repl".open(_A[1], _A[2])',
        \ [[], { 'conn-name': a:conn.cb_data.name }])
  call nvlime#ui#repl#AppendOutput(bufnr, a:str)
endfunction

function! nvlime#ui#OnReadString(conn, thread, ttag) dict
  call nvlime#ui#input#FromBuffer(
        \ a:conn, 'Input string:', v:null,
        \ function('s:ReadStringInputComplete', [a:thread, a:ttag]))
endfunction

function! nvlime#ui#OnReadFromMiniBuffer(conn, thread, ttag, prompt, init_val) dict
  call nvlime#ui#input#FromBuffer(
        \ a:conn, a:prompt, a:init_val,
        \ function('s:ReturnMiniBufferContent', [a:thread, a:ttag]))
endfunction

function! nvlime#ui#OnIndentationUpdate(conn, indent_info) dict
  if !has_key(a:conn.cb_data, 'indent_info')
    let a:conn.cb_data['indent_info'] = {}
  endif
  for i in a:indent_info
    let a:conn.cb_data['indent_info'][i[0]] = [i[1], i[2]]
  endfor
endfunction

function! nvlime#ui#OnNewFeatures(conn, new_features)
  let new_features = (a:new_features is v:null) ? [] : a:new_features
  let a:conn.cb_data['features'] = new_features
endfunction

function! nvlime#ui#OnInvalidRPC(conn, rpc_id, err_msg) dict
  call nvlime#ui#ErrMsg(a:err_msg)
endfunction

function! nvlime#ui#OnInspect(conn, content, thread, tag) dict
  let [_, bufnr] = luaeval('require"nvlime.window.inspector".open(_A)', a:content)
  if a:thread isnot v:null
    call a:ui.SetCurrentThread(a:thread, bufnr)
    if a:tag isnot v:null
      execute 'autocmd BufWinLeave <buffer> ++once call b:nvlime_conn.Return('
            \ .. a:thread .. ', ' .. a:tag .. ', v:null)'
    endif
  endif
endfunction

function! nvlime#ui#OnTraceDialog(conn, spec_list, trace_count) dict
  let trace_buf = nvlime#ui#trace_dialog#InitTraceDialogBuf(a:conn)
  call nvlime#ui#OpenBufferWithWinSettings(trace_buf, v:false, 'trace')
  call nvlime#ui#trace_dialog#FillTraceDialogBuf(a:spec_list, a:trace_count)
endfunction

function! nvlime#ui#OnXRef(conn, xref_list) dict
  if a:xref_list is v:null
    call nvlime#ui#ErrMsg('No xref found.')
  elseif type(a:xref_list) == v:t_dict &&
        \ a:xref_list['name'] == 'NOT-IMPLEMENTED'
    call nvlime#ui#ErrMsg('Not implemented.')
  else
    call nvlime#ui#xref#OpenXRefBuf(a:conn, a:xref_list)
  endif
endfunction

function! nvlime#ui#OnCompilerNotes(conn, note_list, orig_win) dict
  if a:note_list is v:null | return | endif

  let [_, bufnr] = luaeval('require"nvlime.window.main.notes".open(_A)',
        \ { 'conn-name': a:conn.cb_data.name })
  call setbufvar(bufnr, 'nvlime_notes_orig_win', a:orig_win)
  call setbufvar(bufnr, 'nvlime_conn', a:conn)
  call nvlime#ui#compiler_notes#FillCompilerNotesBuf(a:note_list)
endfunction

function! nvlime#ui#OnThreads(conn, thread_list) dict
  if a:thread_list is v:null
    call nvlime#ui#ErrMsg('The thread list is empty.')
    return
  endif

  call nvlime#ui#threads#FillThreadsBuf(a:conn, a:thread_list)
endfunction

function! s:ReturnMiniBufferContent(thread, ttag)
  let content = nvlime#ui#CurBufferContent()
  call b:nvlime_conn.Return(a:thread, a:ttag, content)
endfunction

""
" @public
"
" Return the current character under the cursor. If there's no character, an
" empty string is returned.
function! nvlime#ui#CurChar()
  return matchstr(getline('.'), '\%' . col('.') . 'c.')
endfunction

""
" @public
"
" If there is a parentheses-enclosed expression under the cursor, return it.
" Otherwise look for an atom under the cursor. Return an empty string if
" nothing is found.
function! nvlime#ui#CurExprOrAtom()
  let str = nvlime#ui#CurExpr()
  if len(str) <= 0
    let str = nvlime#ui#CurAtom()
  endif
  return str
endfunction

""
" @public
"
" Return the atom under the cursor, or an empty string if there is no atom.
function! nvlime#ui#CurAtom()
  let old_kw = &iskeyword
  try
    setlocal iskeyword+=+,-,*,/,%,<,=,>,:,$,?,!,@-@,94,~,#,\|,&,.,{,},[,]
    return expand('<cword>')
  finally
    let &l:iskeyword = old_kw
  endtry
endfunction

function! nvlime#ui#CurSymbol()
  let sym = nvlime#ui#CurAtom()
  if len(sym) > 0
    return "'" . sym
  endif
endfunction

""
" @usage [return_pos]
" @public
"
" Return the parentheses-enclosed expression under the cursor, or an empty
" string, when there is no expression.
" If [return_pos] is specified and |TRUE|, return a list containing the
" expression, as well as the beginning and ending positions.
function! nvlime#ui#CurExpr(...)
  let return_pos = get(a:000, 0, v:false)

  let cur_char = nvlime#ui#CurChar()
  let from_pos = nvlime#ui#CurExprPos(cur_char, 'begin')
  let to_pos = nvlime#ui#CurExprPos(cur_char, 'end')
  let expr = nvlime#ui#GetText(from_pos, to_pos)
  return return_pos ? [expr, from_pos, to_pos] : expr
endfunction

let s:cur_expr_pos_search_flags = {
      \ 'begin': ['cbnW', 'bnW', 'bnW'],
      \ 'end':   ['nW', 'cnW', 'nW'],
      \ }

""
" @usage {cur_char} [side]
" @public
"
" Return the beginning or ending position of the parentheses-enclosed
" expression under the cursor.
" {cur_char} is the character under the cursor, which can be obtained by
" calling @function(nvlime#ui#CurChar).
" If [side] is "begin", the beginning position is returned. If [side] is
" "end", the ending position is returned. "begin" is the default when [side]
" is omitted.
function! nvlime#ui#CurExprPos(cur_char, ...)
  let side = get(a:000, 0, 'begin')

  " This paragraph taken from https://github.com/vim/vim/blob/master/runtime/plugin/matchparen.vim
  " VIM License applies, see root directory
  if !has("syntax") || !exists("g:syntax_on")
    let s_skip = "0"
  else
    " Build an expression that detects whether the current cursor position is
    " in certain syntax types (string, comment, etc.), for use as
    " searchpairpos()'s skip argument.
    " We match "escape" for special items, such as lispEscapeSpecial.
    let s_skip = '!empty(filter(map(synstack(line("."), col(".")), ''synIDattr(v:val, "name")''), ' .
          \ '''v:val =~? "string\\|character\\|singlequote\\|escape\\|symbol\\|comment"''))'
    " If executing the expression determines that the cursor is currently in
    " one of the syntax types, then we want searchpairpos() to find the pair
    " within those syntax types (i.e., not skip).  Otherwise, the cursor is
    " outside of the syntax types and s_skip should keep its value so we skip
    " any matching pair inside the syntax types.
    " Catch if this throws E363: pattern uses more memory than 'maxmempattern'.
    try
      execute 'if ' . s_skip . ' | let s_skip = "0" | endif'
    catch /^Vim\%((\a\+)\)\=:E363/
      " We won't find anything, so skip searching, should keep Vim responsive.
      return
    endtry
  endif
  " End of vim include


  if a:cur_char == '('
    return searchpairpos('(', '', ')', s:cur_expr_pos_search_flags[side][0], s_skip)
  elseif a:cur_char == ')'
    return searchpairpos('(', '', ')', s:cur_expr_pos_search_flags[side][1], s_skip)
  else
    return searchpairpos('(', '', ')', s:cur_expr_pos_search_flags[side][2], s_skip)
  endif
endfunction

""
" @usage [return_pos]
" @public
"
" Return the top-level parentheses-enclosed expression. See
" @function(nvlime#ui#CurExpr) for the use of [return_pos].
function! nvlime#ui#CurTopExpr(...)
  let return_pos = get(a:000, 0, v:false)

  let [s_line, s_col] = nvlime#ui#CurTopExprPos('begin')
  if s_line > 0 && s_col > 0
    let old_cur_pos = getcurpos()
    try
      call setpos('.', [0, s_line, s_col, 0])
      return nvlime#ui#CurExpr(return_pos)
    finally
      call setpos('.', old_cur_pos)
    endtry
  else
    return return_pos ? ['', [0, 0], [0, 0]] : ''
  endif
endfunction

""
" @usage [flags]
" @public
"
" Tiny searchpairpos() wrapper tailored for searching pairs of matching
" parenthesis.
"
" It automatically skips matches found inside certain syntax regions like:
" - escape (i.e. lispEscapeSpecial)
" - symbol (i.e. lispBarSymbol)
"
" See `:help search" for the use of [flags].
function! nvlime#ui#SearchParenPos(flags)
  let skipped_regions_fn = '!empty(filter(map(synstack(line("."), col(".")), ''synIDattr(v:val, "name")''), ' .
        \ '''v:val =~? "string\\|character\\|singlequote\\|escape\\|symbol\\|comment"''))'

  return searchpairpos('(', '', ')', a:flags, skipped_regions_fn)
endfunction

""
" @usage [side] [max_level] [max_lines]
" @public
"
" Return the beginning or ending position of the top-level
" parentheses-enclosed expression under the cursor. See
" @function(nvlime#ui#CurExprPos) for the use of [side].
"
" Stop when [max_level] parentheses are seen, or [max_lines] lines have been
" searched. Pass v:null or ommit these two arguments to impose no limit at
" all.
function! nvlime#ui#CurTopExprPos(...)
  let side = get(a:000, 0, 'begin')
  let max_level = get(a:000, 1, v:null)
  let max_lines = get(a:000, 2, v:null)

  if side == 'begin'
    let search_flags = 'bW'
  elseif side == 'end'
    let search_flags = 'W'
  endif

  let last_pos = [0, 0]

  let old_cur_pos = getcurpos()
  let cur_level = 1
  try
    while max_level is v:null || cur_level <= max_level
      let cur_pos = nvlime#ui#SearchParenPos(search_flags)
      if cur_pos[0] <= 0 || cur_pos[1] <= 0 ||
            \ (max_lines isnot v:null && abs(old_cur_pos[1] - cur_pos[0]) > max_lines)
        break
      endif
      if !s:InComment(cur_pos) && !s:InString(cur_pos)
        let last_pos = cur_pos
        let cur_level += 1
      endif
    endwhile
    if last_pos[0] > 0 && last_pos[1] > 0
      return last_pos
    else
      let cur_char = nvlime#ui#CurChar()
      if cur_char == '(' || cur_char == ')'
        return nvlime#ui#SearchParenPos(search_flags . 'c')
      else
        return [0, 0]
      endif
    endif
  finally
    call setpos('.', old_cur_pos)
  endtry
endfunction

""
" @usage [max_level] [max_lines]
" @public
"
" Retrieve the parentheses-enclosed expression under the cursor, and parse it
" into a "raw form" usable by @function(NvlimeConnection.Autodoc). See the
" source of SWANK:AUTODOC for an explanation of the raw forms.
"
" The raw-form-parsing operation is quite slow, you can pass [max_level] and
" [max_lines] to impose some limits when searching for expressions. See
" @function(nvlime#ui#CurTopExprPos) for the use of these arguments.
function! nvlime#ui#CurRawForm(...)
  " Note that there may be an incomplete expression
  let max_level = get(a:000, 0, v:null)
  let max_lines = get(a:000, 1, v:null)

  let s_pos = nvlime#ui#CurTopExprPos('begin', max_level, max_lines)
  let [s_line, s_col] = s_pos
  if s_line <= 0 || s_col <= 0
    return []
  endif

  let cur_pos = getcurpos()[1:2]
  let cur_pos[1] -= 1
  let partial_expr = nvlime#ui#GetText(s_pos, cur_pos)
  let partial_expr = substitute(partial_expr, '\v(\_s)+$', ' ', '')

  if len(partial_expr) <= 0
    return []
  endif

  return nvlime#Memoize({-> nvlime#ToRawForm(partial_expr)[0]},
        \ partial_expr, 'raw_form_cache', s:, 1024)
endfunction

""
" @public
"
" Search for an "in-package" expression in the current buffer, and return the
" package name specified in that expression. If no such an expression can be
" found, an empty string is returned.
function! nvlime#ui#CurInPackage()
  let pattern = '(\_s*in-package\_s\+\(.\+\)\_s*)'
  let old_cur_pos = getcurpos()
  try
    let package_line = search(pattern, 'bcW')
    if package_line <= 0
      let package_line = search(pattern, 'cW')
    endif
    if package_line > 0
      let matches = matchlist(nvlime#ui#CurExpr(), pattern)
      " The pattern used here does not check for lone parentheses,
      " so there may not be a match.
      let package = (len(matches) > 0) ? s:NormalizePackageName(matches[1]) : ''
    else
      let package = ''
    endif
    return package
  finally
    call setpos('.', old_cur_pos)
  endtry
endfunction

""
" @public
"
" Return the operator symbol name of the parentheses-enclosed expression under
" the cursor. If no expression is found, return an empty string.
function! nvlime#ui#CurOperator()
  " There may be an incomplete expression, so instead of
  " @function(nvlime#ui#CurExpr) we use searchpairpos() instead
  let [s_line, s_col] = nvlime#ui#SearchParenPos('cbnW')
  if s_line > 0 && s_col > 0
    let op_line = getline(s_line)[(s_col-1):]
    let matches = matchlist(op_line, '^(\s*\(\k\+\)\s*')
    if len(matches) > 0
      return matches[1]
    endif
  endif
  return ''
endfunction

""
" @public
"
" Similar to @function(nvlime#ui#CurOperator), but return the operator of the
" surrounding expression instead, if the cursor is on the left enclosing
" parentheses.
function! nvlime#ui#SurroundingOperator()
  let [s_line, s_col] = nvlime#ui#SearchParenPos('bnW')
  if s_line > 0 && s_col > 0
    let op_line = getline(s_line)[(s_col-1):]
    let matches = matchlist(op_line, '^(\s*\(\k\+\)\s*')
    if len(matches) > 0
      return matches[1]
    endif
  endif
  return ''
endfunction

function! nvlime#ui#ParseOuterOperators(max_count)
  let stack = []
  let old_cur_pos = getcurpos()
  try
    while len(stack) < a:max_count
      let [p_line, p_col] = nvlime#ui#SearchParenPos('bnW')
      if p_line <= 0 || p_col <= 0
        break
      endif
      let cur_pos = nvlime#ui#CurArgPos([p_line, p_col])

      call setpos('.', [0, p_line, p_col, 0])
      let cur_op = nvlime#ui#CurOperator()
      call add(stack, [cur_op, cur_pos, [p_line, p_col]])
    endwhile
  finally
    call setpos('.', old_cur_pos)
  endtry

  return stack
endfunction

""
" @usage [return_pos]
" @public
"
" Return the content of current/last selection. See
" @function(nvlime#ui#CurExpr) for the use of [return_pos].
function! nvlime#ui#CurSelection(...)
  let return_pos = get(a:000, 0, v:false)
  let sel_start = getpos("'<")
  let sel_end = getpos("'>")
  let lines = getline(sel_start[1], sel_end[1])
  if sel_start[1] == sel_end[1]
    let lines[0] = lines[0][(sel_start[2]-1):(sel_end[2]-1)]
  else
    let lines[0] = lines[0][(sel_start[2]-1):]
    let last_idx = len(lines) - 1
    let lines[last_idx] = lines[last_idx][:(sel_end[2]-1)]
  endif

  if return_pos
    return [join(lines, "\n"), sel_start[1:2], sel_end[1:2]]
  else
    return join(lines, "\n")
  endif
endfunction

""
" @usage [raw]
" @public
"
" Get the text content of the current buffer. Lines starting with ";" will be
" dropped, unless [raw] is specified and |TRUE|.
function! nvlime#ui#CurBufferContent(raw = v:false)
  let lines = getline(1, '$')
  if !a:raw
    let lines = filter(lines, { _, line -> line !~ '^\s*;' })
  endif

  return join(lines, "\n")
endfunction

""
" @public
"
" Retrieve the text in the current buffer from {from_pos} to {to_pos}.
" These positions should be lists in the form [<line>, <col>].
function! nvlime#ui#GetText(from_pos, to_pos)
  let [s_line, s_col] = a:from_pos
  let [e_line, e_col] = a:to_pos

  let lines = getline(s_line, e_line)
  if len(lines) == 1
    let lines[0] = strpart(lines[0], s_col - 1, e_col - s_col + 1)
  elseif len(lines) > 1
    let lines[0] = strpart(lines[0], s_col - 1)
    let lines[-1] = strpart(lines[-1], 0, e_col)
  endif

  return join(lines, "\n")
endfunction

function! nvlime#ui#GetCurWindowLayout()
  let old_win = win_getid()
  let layout = []
  let old_ei = &eventignore
  let &eventignore = 'all'
  try
    windo call add(layout,
          \ {'id': win_getid(),
          \ 'height': winheight(0),
          \ 'width': winwidth(0)})
    return layout
  finally
    call win_gotoid(old_win)
    let &eventignore = old_ei
  endtry
endfunction

function! nvlime#ui#RestoreWindowLayout(layout)
  if len(a:layout) != winnr('$')
    return
  endif

  let old_win = win_getid()
  let old_ei = &eventignore
  let &eventignore = 'all'
  try
    for ws in a:layout
      if win_gotoid(ws['id'])
        execute 'resize' ws['height']
        execute 'vertical resize' ws['width']
      endif
    endfor
  finally
    call win_gotoid(old_win)
    let &eventignore = old_ei
  endtry
endfunction

""
" @public
"
" Call {Func}. When {Func} returns, move the cursor back to the current
" window.
function! nvlime#ui#KeepCurWindow(Func)
  let cur_win_id = win_getid()
  try
    return a:Func()
  finally
    call win_gotoid(cur_win_id)
  endtry
endfunction

""
" @usage {buf} {Func} [ev_ignore]
" @public
"
" Call {Func} with {buf} set as the current buffer. {buf} should be an
" expression as described in |bufname()|. [ev_ignore] specifies what
" autocmd events to ignore when switching buffers. When [ev_ignore] is
" omitted, all events are ignored by default.
function! nvlime#ui#WithBuffer(buf, Func, ev_ignore = 'all')
  let buf_win = bufwinid(a:buf)
  let buf_visible = (buf_win >= 0) ? v:true : v:false

  let old_win = win_getid()

  let old_lazyredraw = &lazyredraw
  let &lazyredraw = 1

  let old_ei = &eventignore
  let &eventignore = a:ev_ignore

  try
    if buf_visible
      call win_gotoid(buf_win)
      try
        let &eventignore = old_ei
        return a:Func()
      finally
        let &eventignore = a:ev_ignore
      endtry
    else
      let old_layout = nvlime#ui#GetCurWindowLayout()
      try
        silent call nvlime#ui#OpenBuffer(a:buf, v:false)
        let tmp_win_id = win_getid()
        try
          let &eventignore = old_ei
          return a:Func()
        finally
          let &eventignore = a:ev_ignore
          execute win_id2win(tmp_win_id) . 'wincmd c'
        endtry
      finally
        call nvlime#ui#RestoreWindowLayout(old_layout)
      endtry
    endif
  finally
    call win_gotoid(old_win)
    let &lazyredraw = old_lazyredraw
    let &eventignore = old_ei
  endtry
endfunction

""
" @public
"
" Open a buffer with the specified {name}.
" {name} should be an expression as described in |bufname()|. Return -1 if the
" buffer doesn't exist, unless {create} is |TRUE|. In that case, a new buffer
" is created.
"
" When [pos] is empty string or one of "aboveleft", "belowright",
" "topleft", or "botright", to further specify the window position. See
" |aboveleft| and the alike to get explanations of these positions.
" If buffer is already visible, then just jump to that window instead.
"
" [vertical], if specified and |TRUE|, indicates that the new window should be
" created vertically. [initial_size] assigns an initial size to the newly
" created window.
function! nvlime#ui#OpenBuffer(name, create, pos = '', vertical = v:false, initial_size = 0)
  let buf = bufnr(a:name, a:create)
  if buf <= 0 | return buf | endif

  let winid = bufwinid(buf)
  if winid < 0
    if len(a:pos) > 0
      let split_cmd = 'split #' .. buf
      if a:vertical
        let split_cmd = 'vertical ' .. split_cmd
      endif
      if a:initial_size > 0
        let split_cmd = a:initial_size .. split_cmd
      endif
      " Use silent! to suppress the 'Illegal file name' message
      " and E303: Unable to open swap file...
      silent! execute a:pos split_cmd
    else
      silent! execute 'split #' .. buf
    endif
  else
    call nvim_set_current_win(winid)
  endif
  return buf
endfunction

""
" @public
"
" Like @function(nvlime#ui#OpenBuffer), but consult |g:nvlime_window_settings|
" when creating a new window. {buf_name} should be an expression as described
" in |bufname()|. {buf_create} specifies whether to create a new buffer or
" not. {win_name} is the type of the window to create. See
" |g:nvlime_window_settings| for a list of Nvlime window types.
function! nvlime#ui#OpenBufferWithWinSettings(buf_name, buf_create, win_name)
  let [win_pos, win_size, win_vert] = nvlime#ui#GetWindowSettings(a:win_name)
  return nvlime#ui#OpenBuffer(a:buf_name, a:buf_create, win_pos, win_vert, win_size)
endfunction

""
" @public
"
" Close all windows that contain {buf}. It's like "execute 'bunload!' {buf}",
" but the buffer remains loaded, and the local settings for {buf} are kept.
" {buf} should be a buffer number as returned by |bufnr()|.
function! nvlime#ui#CloseBuffer(buf)
  let win_id_list = win_findbuf(a:buf)
  if len(win_id_list) <= 0
    return
  endif

  let cur_win_id = win_getid()
  let close_cur_win = v:false
  let old_lazyredraw = &lazyredraw

  try
    let &lazyredraw = 1
    for win_id in win_id_list
      if win_id == cur_win_id
        let close_cur_win = v:true
      elseif win_gotoid(win_id)
        wincmd c
      endif
    endfor
  finally
    if win_gotoid(cur_win_id) && close_cur_win
      wincmd c
    endif
    let &lazyredraw = old_lazyredraw
  endtry
endfunction

function! nvlime#ui#ShowDisassembleForm(conn, content)
  if a:content is v:null
    call nvlime#ui#ErrMsg("Blank disassemble.")
  endif
  call luaeval('require"nvlime.window.disassembly".open(_A)', a:content)
endfunction

""
" @public
"
" Show {content} in the arglist buffer. {conn} should be a
" @dict(NvlimeConnection).
function! nvlime#ui#ShowArgList(conn, content)
  if !exists('#NvlimeArgListInit')
    augroup NvlimeArgListInit
      autocmd!
      let escaped_name = escape(nvlime#ui#ArgListBufName(), ' |\' .. '/')
      execute 'autocmd BufWinEnter' escaped_name 'setlocal conceallevel=2'
    augroup end
  endif

  call luaeval('require"nvlime.window.arglist".show(_A)', a:content)
endfunction

""
" @public
"
" Return a list of windows containing buffers of filetype {ft}.
function! nvlime#ui#GetFiletypeWindowList(ft)
  let winid_list = []
  let old_win_id = win_getid()
  try
    windo if &filetype == a:ft |
          \ call add(winid_list, [win_getid(), bufname('%')]) |
          \ endif
  finally
    call win_gotoid(old_win_id)
  endtry

  return winid_list
endfunction

""
" @public
"
" Close Nvlime windows. See @function(nvlime#ui#GetWindowList) for the use of
" {conn} and {win_name}.
function! nvlime#ui#CloseWindow(conn, win_name)
  let winid_list = nvlime#ui#GetWindowList(a:conn, a:win_name)
  for [winid, bufname] in winid_list
    let winnr = win_id2win(winid)
    if winnr > 0
      execute winnr . 'wincmd c'
    endif
  endfor
endfunction

""
" @public
"
" Append {str} to [line] in the current buffer. Append to the last line if
" [line] is omitted. Elaborately handle newline characters.
function! nvlime#ui#AppendString(str, line = v:null)
  let last_line_nr = line('$')
  let to_append = a:line is v:null ? last_line_nr : a:line

  let new_lines = split(a:str, "\n", v:true)
  let sidx = 0
  let eidx = -1

  if to_append > 0 " && len(new_lines) > 0
    let line_to_append = getline(to_append)
    call setline(to_append, line_to_append .. new_lines[0])
    let sidx = 1
  endif

  if to_append < last_line_nr && len(new_lines) > 1
    let line_after_append = getline(to_append + 1)
    call setline(to_append + 1, new_lines[-1] .. line_after_append)
    let eidx = -2
  endif

  call append(to_append, new_lines[sidx:eidx])

  if a:line is v:null
    call cursor(line('$'), 1)
  endif

  " How many new lines are added.
  return len(new_lines) + eidx - sidx + 1
endfunction

""
" @usage {str} [first_line] [last_line]
" @public
"
" Replace the content of the current buffer, from [first_line] to [last_line]
" (inclusive), with {str}. If [first_line] is omitted, start from line 1. If
" [last_line] is omitted, stop at the last line of the current buffer.
function! nvlime#ui#ReplaceContent(str, first_line = 1, last_line = '$')
  execute a:first_line .. ',' .. a:last_line .. 'delete _'

  if a:first_line > 1
    let str = "\n" .. a:str
  else
    let str = a:str
  endif
  let ret = nvlime#ui#AppendString(str, a:first_line - 1)
  call cursor([a:first_line, 1, 0, 1])
  return ret
endfunction

""
" @public
"
" Adjust the indentation of the current line. {indent} is the amount to
" indent, in number of space characters.
function! nvlime#ui#IndentCurLine(indent)
  if &expandtab
    let indent_str = repeat(' ', a:indent)
  else
    " Ah! So bad! Such evil!
    let indent_str = repeat("\<tab>", a:indent / &tabstop)
    let indent_str .= repeat(' ', a:indent % &tabstop)
  endif
  let line = getline('.')
  let new_line = substitute(line, '^\(\s*\)', indent_str, '')
  call setline('.', new_line)
  let spaces = nvlime#ui#CalcLeadingSpaces(new_line)
  call setpos('.', [0, line('.'), spaces + 1, 0, a:indent + 1])
endfunction

""
" @usage [pos]
" @public
"
" Return the index of the argument under the cursor, inside a
" parentheses-enclosed expression. A returned value of zero means the cursor
" is on the operator. If no parentheses-enclosed expression is found, -1 is
" returned. [pos] should be the position where the parentheses-enclosed
" expression begins, in the form [<line>, <col>]. If [pos] is omitted, this
" function will try to find the beginning position.
function! nvlime#ui#CurArgPos(...)
  let s_pos = get(a:000, 0, v:null)
  let arg_pos = -1

  if s_pos is v:null
    let [s_line, s_col] = nvlime#ui#SearchParenPos('bnW')
  else
    let [s_line, s_col] = s_pos
  endif
  if s_line <= 0 || s_col <= 0
    return arg_pos
  endif

  let cur_pos = getcurpos()
  let paren_count = 0
  let last_type = ''

  for ln in range(s_line, cur_pos[1])
    let line = getline(ln)
    let start_idx = (ln == s_line) ? (s_col - 1) : 0
    if ln == cur_pos[1]
      let end_idx = min([cur_pos[2], len(line)])
      if cur_pos[2] > len(line)
        let end_itr = end_idx + 1
      else
        let end_itr = end_idx
      endif
    else
      let end_idx = len(line)
      let end_itr = end_idx + 1
    endif

    let idx = start_idx
    while idx < end_itr
      if idx < end_idx
        let ch = line[idx]
      elseif idx < len(line)
        break
      else
        let ch = "\n"
      endif

      let syntax = map(synstack(ln, idx), 'synIDattr(v:val, "name")')

      if index(syntax, 'lispComment') >= 0
        " do nothing
      elseif last_type == '\'
        let last_type = 'i'
      elseif ch == '\'
        let last_type = '\'
      elseif ch == ' ' || ch == "\<tab>" || ch == "\n"
        if last_type != 's' && last_type != ')' && paren_count == 1
          let arg_pos += 1
        endif
        let last_type = 's'
      elseif ch == '('
        let paren_count += 1
        if last_type == '(' && paren_count == 2
          let arg_pos += 1
        endif
        let last_type = '('
      elseif ch == ')'
        let paren_count -= 1
        if paren_count == 1
          let arg_pos += 1
        endif
        let last_type = ')'
      else
        " identifiers
        if last_type != 's' && last_type != ')' && last_type != 'i' && paren_count == 1
          let arg_pos += 1
        endif
        let last_type = 'i'
      endif

      let idx += 1
    endwhile

    let last_type = 's'
  endfor

  return arg_pos
endfunction

function! nvlime#ui#Pad(prefix, sep, max_len)
  return a:prefix .. a:sep .. repeat(' ', a:max_len + 1 - strdisplaywidth(a:prefix))
endfunction

""
" @public
"
" Show an error message.
function! nvlime#ui#ErrMsg(msg)
  redraw
  echohl ErrorMsg
  echom a:msg
  echohl None
endfunction

function! nvlime#ui#SetNvlimeBufferOpts(buf, conn)
  call setbufvar(a:buf, '&buftype', 'nofile')
  call setbufvar(a:buf, '&bufhidden', 'hide')
  call setbufvar(a:buf, '&swapfile', 0)
  call setbufvar(a:buf, '&buflisted', 1)
  call setbufvar(a:buf, 'nvlime_conn', a:conn)
endfunction

function! nvlime#ui#NvlimeBufferInitialized(buf)
  return getbufvar(a:buf, 'nvlime_conn', v:null) isnot v:null
endfunction

function! nvlime#ui#MatchCoord(coord, cur_line, cur_col)
  let c_begin = get(a:coord, 'begin', v:null)
  let c_end = get(a:coord, 'end', v:null)
  if c_begin is v:null || c_end is v:null
    return v:false
  endif

  if c_begin[0] == c_end[0] && a:cur_line == c_begin[0]
        \ && a:cur_col >= c_begin[1]
        \ && a:cur_col <= c_end[1]
    return v:true
  elseif c_begin[0] < c_end[0]
    if a:cur_line == c_begin[0] && a:cur_col >= c_begin[1]
      return v:true
    elseif a:cur_line == c_end[0] && a:cur_col <= c_end[1]
      return v:true
    elseif a:cur_line > c_begin[0] && a:cur_line < c_end[0]
      return v:true
    endif
  endif

  return v:false
endfunction

function! nvlime#ui#FindNextCoord(cur_pos, sorted_coords, forward = v:true)
  let next_coord = v:null
  for c in a:sorted_coords
    if a:forward
      if c['begin'][0] > a:cur_pos[0]
        return c
      elseif c['begin'][0] == a:cur_pos[0] && c['begin'][1] > a:cur_pos[1]
        return c
      endif
    else
      if c['begin'][0] < a:cur_pos[0]
        return c
      elseif c['begin'][0] == a:cur_pos[0] && c['begin'][1] < a:cur_pos[1]
        return c
      endif
    endif
  endfor

  return v:null
endfunction

function! nvlime#ui#CoordSorter(direction, c1, c2)
  if a:c1['begin'][0] > a:c2['begin'][0]
    return a:direction ? 1 : -1
  elseif a:c1['begin'][0] == a:c2['begin'][0]
    if a:c1['begin'][1] > a:c2['begin'][1]
      return a:direction ? 1 : -1
    elseif a:c1['begin'][1] == a:c2['begin'][1]
      return 0
    else
      return a:direction ? -1 : 1
    endif
  else
    return a:direction ? -1 : 1
  endif
endfunction

function! nvlime#ui#CoordsToMatchPos(coords)
  let pos_list = []
  for co in a:coords
    if co['begin'][0] == co['end'][0]
      let line = co['begin'][0]
      let col = co['begin'][1]
      let len = co['end'][1] - co['begin'][1] + 1
      call add(pos_list, [line, col, len])
    else
      for line in range(co['begin'][0], co['end'][0])
        if line == co['begin'][0]
          let col = co['begin'][1]
          let len = len(getline(line)) - col + 1
          call add(pos_list, [line, col, len])
        elseif line == co['end'][0]
          let col = 1
          let len = co['end'][1]
          call add(pos_list, [line, col, len])
        else
          call add(pos_list, line)
        endif
      endfor
    endif
  endfor

  return pos_list
endfunction

function! nvlime#ui#MatchAddCoords(group, coords)
  let pos_list = nvlime#ui#CoordsToMatchPos(a:coords)
  let match_list = []
  let stride = 8
  for i in range(0, len(pos_list) - 1, stride)
    call add(match_list, matchaddpos(a:group, pos_list[i:i+stride-1]))
  endfor
  return match_list
endfunction

function! nvlime#ui#MatchDeleteList(match_list)
  for m in a:match_list
    try
      call matchdelete(m)
    catch /^Vim\%((\a\+)\)\=:E803/
    endtry
  endfor
endfunction

""
" @public
"
" Open a file specified by {file_path}, and move the cursor to {byte_pos}. If
" the specified file is already loaded in a window, move the cursor to that
" window instead.
"
" [snippet] is used to fine-tune the cursor position to jump to. One can pass
" v:null to safely ignore the fine-tuning. [edit_cmd] is the command used to
" open the specified file, if it's not loaded in any window yet. The default
" is "hide edit". When [force_open] is specified and |TRUE|, always open the
" file with [edit_cmd].
function! nvlime#ui#JumpToOrOpenFile(file_path, byte_pos, snippet, edit_cmd, force_open)
  " We are using setpos() to jump around the target file, and it doesn't
  " save the locations to the jumplist. We need to save the current location
  " explicitly with m' before running edit_cmd or jumping around in an
  " already-opened file (see :help jumplist).

  if a:force_open
    let buf_exists = v:false
  else
    let file_buf = bufnr(a:file_path)
    let buf_exists = v:true
    if file_buf > 0
      let buf_win = bufwinnr(file_buf)
      if buf_win > 0
        execute buf_win . 'wincmd w'
      else
        let win_list = win_findbuf(file_buf)
        if len(win_list) > 0
          call win_gotoid(win_list[0])
        else
          let buf_exists = v:false
        endif
      endif
    else
      let buf_exists = v:false
    endif
  endif

  if buf_exists
    normal! m'
  else
    " Actually the buffer may exist, but it's not shown in any window
    if type(a:file_path) == v:t_number
      if bufnr(a:file_path) > 0
        try
          normal! m'
          execute a:edit_cmd '#' . a:file_path
        catch /^Vim\%((\a\+)\)\=:E37/  " No write since last change
          " Vim will raise E37 when editing the same buffer with
          " unsaved changes. Double-check it IS the same buffer.
          if bufnr('%') != a:file_path
            throw v:exception
          endif
        endtry
      else
        call nvlime#ui#ErrMsg('Buffer ' . a:file_path . ' does not exist.')
        return
      endif
    elseif a:file_path[0:6] == 'sftp://' || filereadable(a:file_path)
      normal! m'
      execute a:edit_cmd escape(a:file_path, ' \')
    else
      call nvlime#ui#ErrMsg('Not readable: ' . a:file_path)
      return
    endif
  endif

  if a:byte_pos isnot v:null
    let src_line = byte2line(a:byte_pos)
    call setpos('.', [0, src_line, 1, 0, 1])
    let cur_pos = line2byte('.') + col('.') - 1
    if a:byte_pos - cur_pos > 0
      call setpos('.', [0, src_line, a:byte_pos - cur_pos + 1, 0])
    endif
    if a:snippet isnot v:null
      call cursor('.', 1)
      let to_search = '\V' .. substitute(escape(a:snippet, '\'), "\n.*", '', '')
      call search(to_search, 'cW')
    endif
    " Vim may not update the screen when we move the cursor around like
    " this. Force a redraw.
    redraw
  endif
endfunction

""
" @public
"
" Open the source location specified by {loc}.
" {conn} should be a @dict(NvlimeConnection), and {loc} a normalized source
" location returned by @function(nvlime#GetValidSourceLocation). See
" @function(nvlime#ui#JumpToOrOpenFile) for the use of [edit_cmd] and
" [force_open].
function! nvlime#ui#ShowSource(conn, loc, edit_cmd = 'hide edit', force_open = v:false)
  let file_name = a:loc[0]
  let byte_pos = a:loc[1]
  let snippet = a:loc[2]

  if file_name is v:null
    call luaeval('require"nvlime.window.documentation".open(_A)',
          \ "Source form:\n\n" .. snippet)
  else
    call nvlime#ui#JumpToOrOpenFile(file_name, byte_pos, snippet, a:edit_cmd, a:force_open)
  endif
endfunction

function! nvlime#ui#CalcLeadingSpaces(str, expand_tab = v:false)
  if a:expand_tab
    let n_str = substitute(a:str, "\t", repeat(' ', &tabstop), 'g')
  else
    let n_str = a:str
  endif
  let spaces = match(n_str, '[^[:blank:]]')
  if spaces < 0
    let spaces = len(n_str)
  endif
  return spaces
endfunction

function! nvlime#ui#GetEndOfFileCoord()
  let last_line_nr = line('$')
  let last_line = getline(last_line_nr)
  let last_col_nr = len(last_line)
  if last_col_nr <= 0
    let last_col_nr = 1
  endif
  return [last_line_nr, last_col_nr]
endfunction

function! s:SetBufName(...)
  let name = extend(['nvlime:/'], a:000)
  return join(name, '/')
endfunction

function! nvlime#ui#SLDBBufName(conn, thread)
  return s:SetBufName(a:conn.cb_data.name, 'sldb', a:thread)
endfunction

function! nvlime#ui#REPLBufName(conn)
  return s:SetBufName(a:conn.cb_data.name, 'repl')
endfunction

function! nvlime#ui#MREPLBufName(conn, chan_obj)
  return  s:SetBufName(a:conn.cb_data.name, 'mrepl ' .. a:chan_obj['id'])
endfunction

function! nvlime#ui#ArgListBufName()
  return s:SetBufName('arglist')
endfunction

function! nvlime#ui#TraceDialogBufName(conn)
  return s:SetBufName(a:conn.cb_data.name, 'trace')
endfunction

function! nvlime#ui#CompilerNotesBufName(conn)
  return s:SetBufName(a:conn.cb_data.name, 'compiler-notes')
endfunction

function! nvlime#ui#ServerBufName(server_name)
  return s:SetBufName(a:server_name)
endfunction

""
" @public
"
" Return settings for a window type {win_name}. See |g:nvlime_window_settings|
" for the format of the settings and a full list of window types.
function! nvlime#ui#GetWindowSettings(win_name)
  let settings = get(g:nvlime_default_window_settings, a:win_name, v:null)
  if settings is v:null
    throw 'nvlime#ui#GetWindowSettings: unknown window ' .. string(a:win_name)
  else
    let settings = copy(settings)
  endif

  if exists('g:nvlime_window_settings')
    let UserSettings = get(g:nvlime_window_settings, a:win_name, {})
    if type(UserSettings) == v:t_func
      let UserSettings = UserSettings()
    endif
    for sk in keys(UserSettings)
      let settings[sk] = UserSettings[sk]
    endfor
  endif

  return [get(settings, 'pos', 'botright'),
        \ get(settings, 'size', 0),
        \ get(settings, 'vertical', v:false)]
endfunction

""
" @public
"
" Choose a window with |v:count|. The special variable v:count should contain
" a valid window number (see |winnr()|) or zero when this function is called.
" The coresponding window ID is returned. If v:count is zero, try to use
" {default_win} as the result. In that case, if {default_win} is not a legal
" window number, try to find a window automatically.
"
" When all measures fail, zero is returned.
function! nvlime#ui#ChooseWindowWithCount(default_win)
  let count_specified = v:false
  if v:count > 0
    let count_specified = v:true
    let win_to_go = win_getid(v:count)
    if win_to_go <= 0
      call nvlime#ui#ErrMsg('Invalid window number: ' . v:count)
    endif
  elseif a:default_win isnot v:null && win_id2win(a:default_win) > 0
    let win_to_go = a:default_win
  else
    let win_list = nvlime#ui#GetFiletypeWindowList('lisp')
    let win_to_go = (len(win_list) > 0) ? win_list[0][0] : 0
  endif

  return [win_to_go, count_specified]
endfunction

function! nvlime#ui#IsYesString(str)
  return a:str =~? '^y\(es\)\=$'
endfunction

function! s:LogSkippedKey(log, mode, key, cmd, reason)
  if a:log is v:null
    return
  endif
  let buf_type = a:log

  if !exists('g:nvlime_skipped_mappings')
    let g:nvlime_skipped_mappings = {}
  endif

  let buf_skipped_keys = get(g:nvlime_skipped_mappings, buf_type, {})
  let buf_skipped_keys[join([a:mode, a:key], ' ')] = [a:cmd, a:reason]
  let g:nvlime_skipped_mappings[buf_type] = buf_skipped_keys
endfunction

function! s:NormalizePackageName(name)
  let pattern1 = '^\(\(#\?:\)\|''\)\(.\+\)'
  let pattern2 = '"\(.\+\)"'
  let matches = matchlist(a:name, pattern1)
  let r_name = ''
  if len(matches) > 0
    let r_name = matches[3]
  else
    let matches = matchlist(a:name, pattern2)
    if len(matches) > 0
      let r_name = matches[1]
    endif
  endif
  return toupper(r_name)
endfunction

function! s:ReadStringInputComplete(thread, ttag)
  let content = nvlime#ui#CurBufferContent()
  if content[len(content)-1] != "\n"
    let content .= "\n"
  endif
  call b:nvlime_conn.ReturnString(a:thread, a:ttag, content)
endfunction

function! s:InComment(cur_pos)
  let syn_id = synID(a:cur_pos[0], a:cur_pos[1], v:false)
  if syn_id > 0
    return synIDattr(syn_id, 'name') =~ '[Cc]omment'
  else
    if searchpair('#|', '', '|#', 'bnW') > 0
      return v:true
    else
      let line = getline(a:cur_pos[0])
      let semi_colon_idx = match(line, ';')
      if semi_colon_idx >= 0 && (a:cur_pos[1] - 1) > semi_colon_idx
        return v:true
      endif
      return v:false
    endif
  endif
endfunction

function! s:InString(cur_pos)
  let syn_id = synID(a:cur_pos[0], a:cur_pos[1], v:false)
  if syn_id > 0
    return synIDattr(syn_id, 'name') =~ '[Ss]tring'
  else
    let quote_count = 0
    let pattern = '\v((^|[^\\])@<=")|(((^|[^\\])((\\\\)+))@<=")'
    let old_pos = getcurpos()
    try
      let quote_pos = searchpos(pattern, 'bW')
      while quote_pos[0] > 0 && quote_pos[1] > 0
        let quote_count += 1
        let quote_pos = searchpos(pattern, 'bW')
      endwhile
      return (quote_count % 2) > 0
    finally
      call setpos('.', old_pos)
    endtry
  endif
endfunction

let s:special_leader_keys = [
      \ ['<', '<lt>'],
      \ ["\<space>", '<space>'],
      \ ["\<tab>", '<tab>'],
      \ ]

function! s:ExpandSpecialLeaderKeys(leader)
  let res = a:leader
  for [key, repr] in s:special_leader_keys
    let res = substitute(res, key, repr, 'g')
  endfor
  return res
endfunction

let s:default_leader = '\'

let s:leader = get(g:, 'mapleader', s:default_leader)
if len(s:leader) <= 0
  let s:leader = s:default_leader
endif
let s:leader = s:ExpandSpecialLeaderKeys(s:leader)

let s:local_leader = get(g:, 'maplocalleader', s:default_leader)
if len(s:local_leader) <= 0
  let s:local_leader = s:default_leader
endif
let s:local_leader = s:ExpandSpecialLeaderKeys(s:local_leader)

function! s:ExpandLeader(key)
  let to_expand = [['\c<Leader>', s:leader], ['\c<LocalLeader>', s:local_leader]]
  let res = a:key
  for [repr, lkey] in to_expand
    let res = substitute(res, repr, lkey, 'g')
  endfor
  return res
endfunction

" vim: sw=2

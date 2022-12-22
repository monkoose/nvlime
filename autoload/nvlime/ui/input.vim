let g:nvlime_input_history = []

function! nvlime#ui#input#FromBuffer(conn, prompt, init_val, complete_cb)
  let [_, bufnr] = luaeval('require"nvlime.window.input".open(_A[1], _A[2])',
        \ [a:init_val, { 'conn-name': a:conn.cb_data.name, 'prompt': a:prompt}])
  call setbufvar(bufnr, 'nvlime_input_complete_cb', a:complete_cb)
  call cursor('$', len(getline('$')) + 1)
endfunction

function! nvlime#ui#input#MaybeInput(str, str_cb, prompt,
      \ default = '', conn = v:null, comp_type = v:null)
  if a:str is v:null
    if a:conn is v:null
      if a:comp_type is v:null
        let content = input(a:prompt, a:default)
      else
        let content = input(a:prompt, a:default, a:comp_type)
      endif
      call s:CheckInputValidity(content, a:str_cb, v:true)
    else
      let cur_package = a:conn.GetCurrentPackage()
      let cur_buf = bufnr()
      " Oh yeah we LOVE callbacks. You don't go to the hell. The hell
      " comes to you.
      call nvlime#ui#input#FromBuffer(
            \ a:conn, a:prompt,
            \ a:default,
            \ { -> s:CheckInputValidity(nvlime#ui#CurBufferContent(),
            \ { str -> nvlime#ui#WithBuffer(cur_buf, function(a:str_cb, [str]))},
            \ v:true)})
      if bufnr() != cur_buf
        " We set the current package, so that the input buffer has the
        " same context as the the buffer where we initiated the input
        " operation, and completions etc. in the input buffer can work
        " as expected.
        call a:conn.SetCurrentPackage(cur_package)
      endif
    endif
  else
    call s:CheckInputValidity(a:str, a:str_cb, v:false)
  endif
endfunction

function! nvlime#ui#input#FromBufferComplete()
  let buf = bufnr()
  let Callback = getbufvar(buf, 'nvlime_input_complete_cb', v:null)
  if Callback is v:null | return | endif

  if len(nvlime#ui#CurBufferContent()) > 0
    call nvlime#ui#input#SaveHistory(nvlime#ui#CurBufferContent(v:true))
  endif
  if mode() == 'i'
    stopinsert
  endif
  call Callback()

  if bufloaded(buf)
    call nvim_buf_delete(buf, { 'force': v:true })
  endif
endfunction

function! nvlime#ui#input#SaveHistory(text)
  let max_items = get(g:, 'nvlime_input_history_limit', 100)
  let history = g:nvlime_input_history

  if len(history) > 0 && history[-1] == a:text
    return
  endif

  let prev_idx = index(history, a:text)
  while prev_idx >= 0
    call remove(history, prev_idx)
    let prev_idx = index(history, a:text)
  endwhile

  call add(history, a:text)
  if len(history) > max_items
    let delta = len(history) - max_items
    let history = history[delta:-1]
  endif

  let g:nvlime_input_history = history
endfunction

function! nvlime#ui#input#GetHistory(backward = v:true, idx = v:null)
  let history_len = len(g:nvlime_input_history)
  if history_len == 0
    return [0, '']
  endif

  let idx = a:idx is v:null ? history_len : a:idx
  if a:backward
    if idx <= 0
      return [0, '']
    elseif idx > history_len
      let idx = history_len
    endif
    return [idx - 1, g:nvlime_input_history[idx - 1]]
  else
    if idx >= history_len - 1
      return [history_len, '']
    elseif idx < -1
      let idx = -1
    endif
    return [idx + 1, g:nvlime_input_history[idx + 1]]
  endif
endfunction

function! nvlime#ui#input#NextHistoryItem(backward = v:true)
  if exists('b:nvlime_input_history_idx')
    let [next_idx, text] = nvlime#ui#input#GetHistory(
          \ a:backward, b:nvlime_input_history_idx)
  else
    let b:nvlime_input_orig_text = nvlime#ui#CurBufferContent(v:true)
    let [next_idx, text] = nvlime#ui#input#GetHistory(a:backward)
  endif

  let b:nvlime_input_history_idx = next_idx
  if len(text) > 0
    call nvlime#ClearCurrentBuffer()
    call nvlime#ui#AppendString(text)
  elseif next_idx > 0 && exists('b:nvlime_input_orig_text')
    unlet b:nvlime_input_history_idx
    call nvlime#ClearCurrentBuffer()
    call nvlime#ui#AppendString(b:nvlime_input_orig_text)
    unlet b:nvlime_input_orig_text
  endif
  call cursor('$', len(getline('$')) + 1)
endfunction

function! s:CheckInputValidity(str_val, cb, cancellable)
  if len(a:str_val) > 0
    call a:cb(a:str_val)
    return
  endif

  let history_len = len(g:nvlime_input_history)
  if history_len > 0
    call a:cb(g:nvlime_input_history[history_len - 1])
  elseif a:cancellable
    call nvlime#ui#ErrMsg('Canceled.')
  endif
endfunction

" vim: sw=2

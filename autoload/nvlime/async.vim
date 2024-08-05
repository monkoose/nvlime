function! nvlime#async#ch_open(host, port, Callback = v:null, timeout = v:null)
  let chan_obj = {
        \ 'hostname': a:host,
        \ 'port': a:port,
        \ 'on_data': function('s:ChanInputCB'),
        \ 'next_msg_id': 1,
        \ 'msg_callbacks': {},
        \ }
  if a:Callback isnot v:null
    let chan_obj['chan_callback'] = a:Callback
  endif

  try
    let ch_id = sockconnect('tcp', a:host . ':' . a:port, chan_obj)
    let chan_obj['ch_id'] = ch_id
    let chan_obj['is_connected'] = v:true
  catch
    let chan_obj['ch_id'] = v:null
    let chan_obj['is_connected'] = v:false
  endtry

  " XXX: There should be a better way to wait for the channel is ready
  let waittime = (a:timeout isnot v:null) ? (a:timeout + 500) : 500
  execute 'sleep' waittime 'm'

  return chan_obj
endfunction

function! nvlime#async#ch_sendexpr(chan, expr, Callback)
  let msg = [a:chan.next_msg_id, a:expr]

  " echomsg 'SEND >>' msg
  let ret = chansend(a:chan.ch_id, json_encode(msg) .. "\n")
  if ret == 0
    let a:chan['is_connected'] = v:false
    throw 'nvlime#async#ch_sendexpr: chansend() failed'
  else
    if a:Callback isnot v:null
      let a:chan.msg_callbacks[a:chan.next_msg_id] = a:Callback
    endif
    call s:IncMsgID(a:chan)
  endif
endfunction


function! nvlime#async#job_start(cmd, opts)
  let buf_name = a:opts['buf_name']
  let Callback = a:opts['callback']
  let ExitCB = a:opts['exit_cb']

  let job_obj = {
        \ 'on_stdout': function('s:JobOutputCB', [Callback]),
        \ 'on_stderr': function('s:JobOutputCB', [Callback]),
        \ 'on_exit': function('s:JobExitCB', [ExitCB]),
        \ }
  if a:opts['use_terminal']
    let job_obj['use_terminal'] = v:true
    let job_obj['job_id'] = termopen(a:cmd, job_obj)
    let job_obj['out_buf'] = bufnr()
  else
    let buf = bufnr(buf_name, v:true)
    call setbufvar(buf, '&buftype', 'nofile')
    call setbufvar(buf, '&bufhidden', 'hide')
    call setbufvar(buf, '&swapfile', 0)
    call setbufvar(buf, '&buflisted', 1)
    call setbufvar(buf, '&modifiable', 0)

    call extend(job_obj, {
          \ 'out_name': buf_name,
          \ 'err_name': buf_name,
          \ 'out_buf': buf,
          \ 'err_buf': buf,
          \ 'use_terminal': v:false,
          \ })
    let job_obj['job_id'] = jobstart(a:cmd, job_obj)
  endif
  return job_obj
endfunction

function! nvlime#async#job_is_active(job)
  let job_info = nvim_get_chan_info(a:job.job_id)
  return !empty(job_info)
endfunction

function! nvlime#async#job_getbufnr(job)
  return get(a:job, 'out_buf', 0)
endfunction

function! s:ChanInputCB(job_id, data, source) dict

  let obj_list = []
  let buffered = get(self, 'recv_buffer', '')
  for frag in a:data
    let buffered ..= frag
    try
      " XXX: what about E488: Trailing characters?
      let json_obj = json_decode(buffered)
      " echomsg 'RECV <<' json_obj
      call add(obj_list, json_obj)
      let buffered = ''
    catch /^Vim\%((\a\+)\)\=:E474/  " Invalid argument
    catch /^Vim\%((\a\+)\)\=:E1510/  " Same as above
      " See https://github.com/monkoose/nvlime/issues/12
    endtry
  endfor

  let self['recv_buffer'] = buffered

  for json_obj in obj_list
    if json_obj[0] == 0
      let CB = get(self, 'chan_callback', v:null)
    else
      try
        let CB = remove(self.msg_callbacks, json_obj[0])
      catch /^Vim\%((\a\+)\)\=:E716/  " Key not present in Dictionary
        let CB = v:null
      endtry
    endif

    if CB isnot v:null
      try
        call CB(self, json_obj[1])
      catch /.*/
        call nvlime#ui#ErrMsg('nvlime: callback failed: ' .. v:exception)
      endtry
    endif
  endfor
endfunction

let s:max_id = float2nr(pow(2, 16))  " 65536

function! s:IncMsgID(chan)
  if a:chan.next_msg_id >= s:max_id
    let a:chan.next_msg_id = 1
  else
    let a:chan.next_msg_id += 1
  endif
endfunction

function! s:JobOutputCB(user_cb, job_id, data, source) dict
  call call(a:user_cb, [a:data])
  if !self.use_terminal
    let buf = (a:source == 'stdout') ? self.out_buf : self.err_buf
    call nvlime#ui#WithBuffer(buf, function('s:AppendToJobBuffer', [a:data]))
  endif
endfunction

function! s:JobExitCB(user_exit_cb, job_id, exit_status, source) dict
  call call(a:user_exit_cb, [a:exit_status])
endfunction

function! s:AppendToJobBuffer(data)
  call setbufvar('%', '&modifiable', 1)
  try
    for line in a:data
      if len(line) > 0
        call append(line('$'), line)
      endif
    endfor
  finally
    call setbufvar('%', '&modifiable', 0)
    call cursor('$', 1)
  endtry
endfunction

" vim: sw=2

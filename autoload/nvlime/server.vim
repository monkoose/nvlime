if !exists('g:nvlime_cl_wait_time')
  let g:nvlime_cl_wait_time = 10 " seconds
endif

if !exists('g:nvlime_cl_wait_interval')
  let g:nvlime_cl_wait_interval = 500 " milliseconds
endif

if !exists('g:nvlime_servers')
  let g:nvlime_servers = {}
endif

if !exists('g:nvlime_next_server_id')
  let g:nvlime_next_server_id = 1
endif

let s:cur_src_path = expand('<sfile>:p')
let s:nvlime_home = fnamemodify(s:cur_src_path, ':h:h:h')
let s:path_sep = s:cur_src_path[len(s:nvlime_home)]

function! nvlime#server#New(auto_connect = v:true, use_terminal = v:false,
      \ name = v:null, cl_impl = v:null)
  if a:name isnot v:null
    let server_name = a:name
  else
    let server_name = 'nvlime server ' .. g:nvlime_next_server_id
  endif
  let [_, bufnr] = luaeval('require"nvlime.window.server".open(_A)', server_name)

  let server_obj = {
        \ 'id': g:nvlime_next_server_id,
        \ 'name': server_name,
        \ 'auto_connect': a:auto_connect,
        \ 'use_terminal': a:use_terminal,
        \ 'cl_impl': a:cl_impl,
        \ }

  let server_job = nvlime#async#job_start(
        \ nvlime#server#BuildServerCommand(a:cl_impl),
        \ {
        \ 'buf_name': bufname(bufnr),
        \ 'callback': function('s:ServerOutputCB', [server_obj, a:auto_connect]),
        \ 'exit_cb': function('s:ServerExitCB', [server_obj]),
        \ 'use_terminal': a:use_terminal,
        \ })

  if !nvlime#async#job_is_active(server_job)
    call luaeval('require"nvlime.buffer"["fill!"](_A[1], _A[2])',
          \ [bufnr, 'Failed to start server.'])
    throw 'nvlime#server#New: failed to start server job'
  endif

  let server_obj['job'] = server_job
  let g:nvlime_servers[g:nvlime_next_server_id] = server_obj
  let g:nvlime_next_server_id += 1
  let server_buf = nvlime#async#job_getbufnr(server_job)
  call setbufvar(server_buf, 'nvlime_server', server_obj)

  return server_obj
endfunction

function! nvlime#server#Stop(server)
  let server_id = s:NormalizeServerID(a:server)
  let r_server = g:nvlime_servers[server_id]
  call jobstop(r_server.job.job_id)
  let buf = nvlime#async#job_getbufnr(r_server.job)
  call nvlime#ui#CloseBuffer(buf)
endfunction

function! nvlime#server#Rename(server, new_name)
  let server_id = s:NormalizeServerID(a:server)
  let r_server = g:nvlime_servers[server_id]
  let old_buf_name = nvlime#ui#ServerBufName(r_server['name'])
  let r_server['name'] = a:new_name
  let old_buf = bufnr(old_buf_name)
  call nvim_buf_set_name(bufnr(old_buf_name), nvlime#ui#ServerBufName(a:new_name))
endfunction

function! nvlime#server#Show(server)
  let server_id = s:NormalizeServerID(a:server)
  let r_server = g:nvlime_servers[server_id]
  let buf = nvlime#async#job_getbufnr(r_server['job'])

  call luaeval('require"nvlime.window.server".open(_A)', r_server.name)
endfunction

function! nvlime#server#Select()
  if len(g:nvlime_servers) == 0
    call nvlime#ui#ErrMsg('No server started.')
    return v:null
  endif

  let server_names = []
  for k in sort(keys(g:nvlime_servers), 'n')
    let server = g:nvlime_servers[k]
    let port = get(server, 'port', 0)
    call add(server_names, k .. '. ' .. server['name'] .. ' (' .. port .. ')')
  endfor

  echohl Question
  echom 'Select server:'
  echohl None
  let server_nr = inputlist(server_names)
  if server_nr == 0
    call nvlime#ui#ErrMsg('Canceled.')
    return v:null
  else
    let server = get(g:nvlime_servers, server_nr, v:null)
    if server is v:null
      call nvlime#ui#ErrMsg('Invalid server ID: ' . server_nr)
      return v:null
    else
      return server
    endif
  endif
endfunction

function! nvlime#server#ConnectToCurServer()
  let port = v:null
  if nvlime#async#job_is_active(b:nvlime_server['job'])
    let port = get(b:nvlime_server, 'port', v:null)
    if port is v:null
      call nvlime#ui#ErrMsg(b:nvlime_server['name'] . ' is not ready.')
    endif
  else
    call nvlime#ui#ErrMsg(b:nvlime_server['name'] . ' is not running.')
  endif

  if port is v:null
    return
  endif

  let conn = nvlime#plugin#ConnectREPL('127.0.0.1', port)
  if conn isnot v:null
    let conn.cb_data['server'] = b:nvlime_server
    let conn_list = get(b:nvlime_server, 'connections', {})
    let conn_list[conn.cb_data['id']] = conn
    let b:nvlime_server['connections'] = conn_list
  endif
endfunction

function! nvlime#server#StopCurServer()
  if get(g:nvlime_servers, b:nvlime_server['id'], v:null) is v:null
    call nvlime#ui#ErrMsg(b:nvlime_server['name'] . ' is not running.')
    return
  endif

  let answer = input('Stop server ' .. string(b:nvlime_server['name']) .. '? (y/n) ')
  if nvlime#ui#IsYesString(answer)
    call nvlime#server#Stop(b:nvlime_server)
  else
    call nvlime#ui#ErrMsg('Canceled.')
  endif
endfunction

function! nvlime#server#BuildServerCommandFor_sbcl(nvlime_loader, nvlime_eval)
  return ['sbcl', '--load', a:nvlime_loader, '--eval', a:nvlime_eval]
endfunction

function! nvlime#server#BuildServerCommandFor_ccl(nvlime_loader, nvlime_eval)
  return ['ccl', '--load', a:nvlime_loader, '--eval', a:nvlime_eval]
endfunction

function! nvlime#server#BuildServerCommand(cl_impl)
  if a:cl_impl is v:null
    let cl_impl = exists('g:nvlime_cl_impl') ? g:nvlime_cl_impl : 'sbcl'
  else
    let cl_impl = a:cl_impl
  endif
  let nvlime_loader = join([s:nvlime_home, 'lisp', 'load-nvlime.lisp'], s:path_sep)

  let user_func_name = 'NvlimeBuildServerCommandFor_' . cl_impl
  let default_func_name = 'nvlime#server#BuildServerCommandFor_' . cl_impl

  if exists('*' . user_func_name)
    let Builder = function(user_func_name)
  elseif exists('*' . default_func_name)
    let Builder = function(default_func_name)
  else
    throw 'nvlime#server#BuildServerCommand: implementation ' .
          \ string(cl_impl) . ' not supported'
  endif

  return Builder(nvlime_loader, '(nvlime:main)')
endfunction

function! s:MatchServerCreatedPort()
  let pattern = 'Server created: (#([[:digit:][:blank:]]\+)\s\+\(\d\+\))'
  let old_pos = getcurpos()
  try
    call cursor([1, 1, 0, 1])
    let port_line_nr = search(pattern, 'n')
  finally
    call setpos('.', old_pos)
  endtry
  if port_line_nr > 0
    let port_line = getline(port_line_nr)
    let matched = matchlist(port_line, pattern)
    return str2nr(matched[1])
  else
    return v:null
  endif
endfunction

function! s:NormalizeServerID(id)
  if type(a:id) == v:t_dict
    return a:id['id']
  else
    return a:id
  endif
endfunction

function! s:ServerOutputCB(server_obj, auto_connect, data)
  if get(a:server_obj, 'port', 0) > 0
    " TODO: unregister this callback
    return
  endif

  for line in a:data
    let matched = matchlist(line, 'Server created: (#([[:digit:][:blank:]]\+)\s\+\(\d\+\))')
    if len(matched) > 0
      let port = str2nr(matched[1])
      let a:server_obj['port'] = port
      echom 'Nvlime server listening on port ' . port

      if a:auto_connect
        let auto_conn = nvlime#plugin#ConnectREPL('127.0.0.1', port)
        if auto_conn isnot v:null
          let auto_conn.cb_data['server'] = a:server_obj
          let a:server_obj['connections'] =
                \ {auto_conn.cb_data['id']: auto_conn}
        endif
      endif

      break
    endif
  endfor
endfunction

function! s:ServerExitCB(server_obj, exit_status)
  call remove(g:nvlime_servers, a:server_obj['id'])
  echom a:server_obj['name'] .. ' stopped.'

  let conn_dict = get(a:server_obj, 'connections', {})
  for conn_id in keys(conn_dict)
    call nvlime#connection#Close(conn_dict[conn_id])
  endfor
  let a:server_obj['connections'] = {}
endfunction

" vim: sw=2

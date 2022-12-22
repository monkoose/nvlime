let s:nvlime_connections = {}
let s:nvlime_next_conn_id = 1

function! nvlime#connection#New(name = v:null)
  if a:name isnot v:null
    let conn_name = a:name
  else
    let conn_name = 'nvlime-' .. s:nvlime_next_conn_id
  endif
  let conn = nvlime#New(
        \ {
        \ 'id': s:nvlime_next_conn_id,
        \ 'name': conn_name
        \ },
        \ nvlime#ui#GetUI())
  let s:nvlime_connections[s:nvlime_next_conn_id] = conn
  let s:nvlime_next_conn_id += 1
  return conn
endfunction

function! nvlime#connection#Close(conn)
  let conn_id = s:NormalizeConnectionID(a:conn)
  let r_conn = remove(s:nvlime_connections, conn_id)
  call r_conn.Close()
endfunction

function! nvlime#connection#Rename(conn, new_name)
  let conn_id = s:NormalizeConnectionID(a:conn)
  let r_conn = s:nvlime_connections[conn_id]
  let r_conn.cb_data['name'] = a:new_name
endfunction

function! nvlime#connection#Select(quiet)
  if len(s:nvlime_connections) == 0
    if !a:quiet
      call nvlime#ui#ErrMsg('Nvlime not connected.')
    endif
    return v:null
  else
    let cur_conn = getbufvar('%', 'nvlime_conn', v:null)
    let cur_conn_id = (cur_conn is v:null) ? -1 : cur_conn.cb_data['id']

    let conn_names = []
    for k in sort(keys(s:nvlime_connections), 'n')
      let conn = s:nvlime_connections[k]
      let disp_name = k .. '. ' .. conn.cb_data['name'] ..
            \ ' (' .. conn.channel['hostname'] .. ':' .. conn.channel['port'] .. ')'
      if cur_conn_id == conn.cb_data['id']
        let disp_name .= ' *'
      endif
      call add(conn_names, disp_name)
    endfor

    echohl Question
    echom 'Which connection to use?'
    echohl None
    let conn_nr = inputlist(conn_names)
    if conn_nr == 0
      if !a:quiet
        call nvlime#ui#ErrMsg('Canceled.')
      endif
      return v:null
    else
      let conn = get(s:nvlime_connections, conn_nr, v:null)
      if conn is v:null
        if !a:quiet
          call nvlime#ui#ErrMsg('Invalid connection ID: ' .. conn_nr)
        endif
        return v:null
      else
        return conn
      endif
    endif
  endif
endfunction

function! nvlime#connection#Get(quiet = v:false) abort
  if !exists('b:nvlime_conn') ||
        \ (b:nvlime_conn isnot v:null && !b:nvlime_conn.IsConnected()) ||
        \ (b:nvlime_conn is v:null && !a:quiet)
    if len(s:nvlime_connections)
      let b:nvlime_conn = s:nvlime_connections[keys(s:nvlime_connections)[0]]
    else
      let conn = nvlime#connection#Select(a:quiet)
      if conn is v:null
        if a:quiet
          " No connection found. Set this variable to v:null to
          " make it 'quiet'
          let b:nvlime_conn = conn
        else
          return conn
        endif
      else
        let b:nvlime_conn = conn
      endif
    endif
  endif
  return b:nvlime_conn
endfunction

function! s:NormalizeConnectionID(id)
  if type(a:id) == v:t_dict
    return a:id.cb_data['id']
  else
    return a:id
  endif
endfunction

" vim: sw=2

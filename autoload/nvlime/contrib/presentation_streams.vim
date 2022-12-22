function! nvlime#contrib#presentation_streams#Init(conn)
  call a:conn.Send(
        \ a:conn.EmacsRex(
        \ [nvlime#SYM('SWANK', 'INIT-PRESENTATION-STREAMS')]),
        \ function('nvlime#SimpleSendCB',
        \ [a:conn, v:null, 'nvlime#contrib#presentation_streams#Init']))
endfunction

" vim: sw=2

if !exists('g:nvlime_contrib_initializers')
  let g:nvlime_contrib_initializers = {
        \ 'SWANK-REPL': function('nvlime#contrib#repl#Init'),
        \ 'SWANK-MREPL': function('nvlime#contrib#mrepl#Init'),
        \ 'SWANK-PRESENTATIONS': function('nvlime#contrib#presentations#Init'),
        \ 'SWANK-PRESENTATION-STREAMS': function('nvlime#contrib#presentation_streams#Init'),
        \ 'SWANK-FUZZY': function('nvlime#contrib#fuzzy#Init'),
        \ 'SWANK-ARGLISTS': function('nvlime#contrib#arglists#Init'),
        \ 'SWANK-TRACE-DIALOG': function('nvlime#contrib#trace_dialog#Init'),
        \ }
endif

function! nvlime#contrib#CallInitializers(conn, contribs = v:null, Callback = v:null)
  let contribs = a:contribs is v:null ?
        \ get(a:conn.cb_data, 'contribs', []) :
        \ a:contribs
  for c in contribs
    let InitFunc = get(g:nvlime_contrib_initializers, c, v:null)
    if type(InitFunc) != v:t_func && exists('g:nvlime_options.user_contrib_initializers')
      " Because it is funcref it doesn't work for now
      " let InitFunc = get(g:nvlime_user_contrib_initializers, c, v:null)
    endif
    if type(InitFunc) == v:t_func
      call call(InitFunc, [a:conn])
    endif
  endfor

  if type(a:Callback) == v:t_func
    call call(a:Callback, [a:conn])
  endif
endfunction

" vim: sw=2

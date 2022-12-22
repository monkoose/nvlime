" Helper functions for nvim-cmp

function nvlime#cmp#get_fuzzy(base, callback)
  silent let connection = nvlime#connection#Get(v:true)
  call l:connection.FuzzyCompletions(a:base,
        \ {c, r -> luaeval('_A[1](_A[2])', [a:callback, r[0]])})
endfunction

function nvlime#cmp#get_simple(base, callback)
  silent let connection = nvlime#connection#Get(v:true)
  call connection.SimpleCompletions(a:base,
        \ {c, r -> luaeval('_A[1](_A[2])', [a:callback, r[0]])})
endfunction

function! nvlime#cmp#get_docs(symbol, callback)
  silent let connection = nvlime#connection#Get(v:true)
  call connection.DocumentationSymbol(a:symbol,
        \ {c, r -> luaeval('_A[1](_A[2])', [a:callback, r])})
endfunction

" vim: sw=2

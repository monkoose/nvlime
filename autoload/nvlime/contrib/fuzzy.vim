""
" @dict NvlimeConnection.FuzzyCompletions
" @public
"
" Get a completion list for {symbol}, using a more clever fuzzy algorithm.
" {symbol} should be a plain string containing a (partial) symbol name.
"
" This method needs the SWANK-FUZZY contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#fuzzy#FuzzyCompletions(symbol, Callback = v:null) dict
  let cur_package = self.GetCurrentPackage()
  if cur_package isnot v:null
    let cur_package = cur_package[0]
  endif
  call self.Send(self.EmacsRex(
        \ [nvlime#SYM('SWANK', 'FUZZY-COMPLETIONS'), a:symbol, cur_package]),
        \ function('nvlime#SimpleSendCB',
        \ [self, a:Callback, 'nvlime#contrib#fuzzy#FuzzyCompletions']))
endfunction

function! nvlime#contrib#fuzzy#Init(conn)
  let a:conn['FuzzyCompletions'] = function('nvlime#contrib#fuzzy#FuzzyCompletions')
endfunction

" vim: sw=2

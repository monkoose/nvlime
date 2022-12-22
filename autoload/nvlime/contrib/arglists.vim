""
" @dict NvlimeConnection.Autodoc
" @usage {raw_form} [margin] [callback]
" @public
"
" Get the arglist description for {raw_form}. {raw_form} should be a value
" returned by @function(nvlime#ui#CurRawForm) or @function(nvlime#ToRawForm).
" See the source of SWANK:AUTODOC for an explanation of the raw forms.
" [margin], if specified and not v:null, gives the line width to wrap to.
"
" This method needs the SWANK-ARGLISTS contrib module. See
" @function(NvlimeConnection.SwankRequire).
function! nvlime#contrib#arglists#Autodoc(raw_form, margin = v:null, Callback = v:null) dict
  let cmd = a:margin is v:null ?
        \ [nvlime#SYM('SWANK', 'AUTODOC'), a:raw_form] :
        \ [nvlime#SYM('SWANK', 'AUTODOC'), a:raw_form,
        \ nvlime#KW('PRINT-RIGHT-MARGIN'), a:margin]
  call self.Send(self.EmacsRex(cmd),
        \ function('nvlime#SimpleSendCB',
        \ [self, a:Callback, 'nvlime#contrib#arglists#Autodoc']))
endfunction

function! nvlime#contrib#arglists#Init(conn)
  let a:conn['Autodoc'] = function('nvlime#contrib#arglists#Autodoc')
endfunction

" vim: sw=2

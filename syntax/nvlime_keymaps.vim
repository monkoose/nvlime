if exists('b:current_syntax')
    finish
endif

syntax match nvlime_keymapsBold "\m\%1l.*"
syntax match nvlime_keymapsFirst "\m\%>1l^\S\+\s\+\S\+" contains=nvlime_keymapsMode,nvlime_keymapsMap
syntax match nvlime_keymapsMode "\m\%>1l^\S\+" contained
syntax match nvlime_keymapsMap "\m\%>1l\s\S\+" contained

hi def nvlime_keymapsBold cterm=bold gui=bold
hi def link nvlime_keymapsMode Function
hi def link nvlime_keymapsMap Statement

let b:current_syntax = 'nvlime_keymaps'

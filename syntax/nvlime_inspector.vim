if exists('b:current_syntax')
    finish
endif

syntax region nvlime_inspectorObject start="\m#<" end="\m>" contains=nvlime_inspectorObject,nvlime_inspectorString
syntax region nvlime_inspectorString start=+\m"+ skip=+\m\\\\\|\\"+ end=+\m"+
syntax match nvlime_inspectorNumber "-\=\(\.\d\+\|\d\+\(\.\d*\)\=\)\([dDeEfFlL][-+]\=\d\+\)\="
syntax match nvlime_inspectorNumber "-\=\(\d\+/\d\+\)"

hi def link nvlime_inspectorObject Constant
hi def link nvlime_inspectorString String
hi def link nvlime_inspectorNumber Number
hi def link nvlime_inspectorAction Function
hi def link nvlime_inspectorValue Constant

let b:current_syntax = 'nvlime_inspector'

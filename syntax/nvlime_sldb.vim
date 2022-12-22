if exists('b:current_syntax')
    finish
endif

syntax match nvlime_sldbSection "\m^Thread: \d\+; Level: \d\+$" contains=nvlime_sldbNumber
syntax match nvlime_sldbSection "\m^Restarts:$"
syntax match nvlime_sldbSection "\m^Frames:$"
syntax match nvlime_sldbRestart "\m\(^\s*\d\+\.\s\+\)\@<=[^[:space:]]\+\(\s\+-\)\@="
syntax match nvlime_sldbNumber "-\=\(\.\d\+\|\d\+\(\.\d*\)\=\)\([dDeEfFlL][-+]\=\d\+\)\="
syntax match nvlime_sldbNumber "-\=\(\d\+/\d\+\)"
syntax region nvlime_sldbString start=+\m"+ skip=+\m\\\\\|\\"+ end=+\m+ end=/$/me=e-1
syntax region nvlime_sldbObject start="\m#<" end="\m>" end="$"me=e-1 contains=nvlime_sldbObject,nvlime_sldbString
syntax match nvlime_sldbFrameLocals "\m^\s*Locals:\s*$"
syntax match nvlime_sldbFrameCatchTags "\m^\s*Catch tags:\s*$"

hi def link nvlime_sldbSection Comment
hi def link nvlime_sldbRestart Operator
hi def link nvlime_sldbNumber Number
hi def link nvlime_sldbString String
hi def link nvlime_sldbObject Constant
hi def nvlime_sldbFrameLocals gui=bold cterm=bold
hi def link nvlime_sldbFrameCatchTags nvlime_sldbFrameLocals

let b:current_syntax = 'nvlime_sldb'

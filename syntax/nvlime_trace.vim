if exists('b:current_syntax')
    finish
endif

syntax region nvlime_traceObject start="\m#<" end="\m>" contains=nvlime_traceObject,nvlime_traceString
syntax region nvlime_traceString start=+\m"+ skip=+\m\\\\\|\\"+ end=+\m"+
syntax match nvlime_traceNumber "-\=\(\.\d\+\|\d\+\(\.\d*\)\=\)\([dDeEfFlL][-+]\=\d\+\)\="
syntax match nvlime_traceNumber "-\=\(\d\+/\d\+\)"
syntax region nvlime_traceButton start="\m\[" end="\m\]"
syntax match nvlime_traceCallChart "\m\(^\s*\d\+ \)\@<=-\( [^ ]\)\@="
syntax match nvlime_traceCallChart "\m\(\(^\|[^ ]\) \+\)\@<=|\( \+[^ ]\)\@="
syntax match nvlime_traceCallChart "\m\([^ ]\+ \+\)\@<=|\?`-\( [^ ]\)\@="
syntax match nvlime_traceArgMarker "\m\(\(^\|[^ ]\) \+\)\@<=>\( [^ ]\)\@="
syntax match nvlime_traceRetValMarker "\m\(\(^\|[^ ]\) \+\)\@<=<\( [^ ]\)\@="

hi def link nvlime_traceObject Constant
hi def link nvlime_traceString String
hi def link nvlime_traceNumber Number
hi def link nvlime_traceButton Operator
hi def link nvlime_traceCallChart Comment
hi def link nvlime_traceArgMarker Comment
hi def link nvlime_traceRetValMarker Comment

let b:current_syntax = 'nvlime_trace'

if exists('b:current_syntax')
    finish
endif

syntax region nvlime_arglistMarkedArg start="\m\(\(^\|[^=]\)===>\(\_s\+\)\)\@<=" end="\m\(\(\_s\+\)<===\($\|[^=]\)\)\@="
syntax region nvlime_arglistMarkedArg start="\m\(\(^\|[^=]\)===>\(\_s\+\)(\)\@<=" end="\m\(\_s\+\)\@="
syntax match nvlime_arglistArgMarker "\m\(^\|[^=]\)\@<====>\(\_s\+\)" conceal
syntax match nvlime_arglistArgMarker "\m\(\_s\+\)<===\($\|[^=]\)\@=" conceal
syntax match nvlime_arglistOperator "\m\(^(\)\@<=[^[:space:]]\+\(\_s\+\)\@="

hi def link nvlime_arglistOperator Operator
hi def link nvlime_arglistArgMarker Comment
hi def link nvlime_arglistMarkedArg Identifier

let b:current_syntax = 'nvlime_arglist'

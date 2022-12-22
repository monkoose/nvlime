if exists('b:current_syntax')
    finish
endif

syntax match nvlime_aproposFunction "\m^\S*\s\s.*function$" contains=nvlime_aproposWhat
syntax match nvlime_aproposOperator "\m^\S*\s\s.*operator$" contains=nvlime_aproposWhat
syntax match nvlime_aproposMacro "\m^\S*\s\s.*macro$" contains=nvlime_aproposWhat
syntax match nvlime_aproposType "\m^\S*\s\s.*type$" contains=nvlime_aproposWhat
syntax match nvlime_aproposVariable "\m^\S*\s\s.*variable$" contains=nvlime_aproposWhat
syntax match nvlime_aproposWhat "\m\s\s\zs.\+$" contained
syntax match nvlime_aproposWhat "\m\s\s\zs.\+$"

hi def link nvlime_aproposFunction Function
hi def link nvlime_aproposOperator Operator
hi def link nvlime_aproposMacro Macro
hi def link nvlime_aproposType Type
hi def link nvlime_aproposVariable Identifier
hi def link nvlime_aproposWhat Comment

let b:current_syntax = 'nvlime_apropos'

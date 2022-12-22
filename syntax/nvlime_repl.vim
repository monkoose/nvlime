if exists('b:current_syntax')
    finish
endif

syntax region nvlime_replComment start="\m\([^\\]\@<=;\)\|\(^;\)" end="\m$" contains=nvlime_replWarning,
      \ nvlime_replError,nvlime_replConditionSummary keepend
syntax match nvlime_replConditionSummary "\m\(\s\|^\)\@<=caught \d\+ .\+ conditions*\(\s\|$\)\@="
syntax match nvlime_replWarning "\m\(\s\|^\)\@<=\(\(WARNING\)\|\(STYLE-WARNING\)\):\(\s\|$\)\@="
syntax match nvlime_replError "\m\(\s\|^\)\@<=ERROR:\(\s\|$\)\@="
syntax region nvlime_replObject start="\m#<" end="\m>" contains=nvlime_replObject,nvlime_replString
syntax region nvlime_replString start=+\m"+ skip=+\m\\\\\|\\"+ end=+\m"+
syntax match nvlime_replNumber "-\=\(\.\d\+\|\d\+\(\.\d*\)\=\)\([dDeEfFlL][-+]\=\d\+\)\="
syntax match nvlime_replNumber "-\=\(\d\+/\d\+\)"
syntax match nvlime_replSeparator +\m^--$+

hi def link nvlime_replSeparator Comment
hi def link nvlime_replObject Constant
hi def link nvlime_replString String
hi def link nvlime_replNumber Constant
hi def link nvlime_replComment Comment
hi def link nvlime_replConditionSummary WarningMsg
hi def link nvlime_replWarning WarningMsg
hi def link nvlime_replError ErrorMsg
hi def link nvlime_replCoord Constant

let b:current_syntax = 'nvlime_repl'

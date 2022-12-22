if exists('b:current_syntax')
    finish
endif

syntax region nvlime_mreplComment start="\m\([^\\]\@<=;\)\|\(^;\)" end="\m$" contains=nvlime_mreplWarning,
      \ nvlime_mreplError,nvlime_mreplConditionSummary keepend
syntax match nvlime_mreplConditionSummary "\m\(\s\|^\)\@<=caught \d\+ .\+ conditions*\(\s\|$\)\@="
syntax match nvlime_mreplWarning "\m\(\s\|^\)\@<=\(\(WARNING\)\|\(STYLE-WARNING\)\):\(\s\|$\)\@="
syntax match nvlime_mreplError "\m\(\s\|^\)\@<=ERROR:\(\s\|$\)\@="
syntax region nvlime_mreplObject start="\m#<" end="\m>" contains=nvlime_mreplObject,nvlime_mreplString
syntax region nvlime_mreplString start=+\m"+ skip=+\m\\\\\|\\"+ end=+\m"+
syntax match nvlime_mreplNumber "-\=\(\.\d\+\|\d\+\(\.\d*\)\=\)\([dDeEfFlL][-+]\=\d\+\)\="
syntax match nvlime_mreplNumber "-\=\(\d\+/\d\+\)"
syntax match nvlime_mreplPrompt "\m^[^>]\+> "

hi def link nvlime_mreplPrompt Comment
hi def link nvlime_mreplObject Constant
hi def link nvlime_mreplString String
hi def link nvlime_mreplNumber Constant
hi def link nvlime_mreplComment Comment
hi def link nvlime_mreplConditionSummary WarningMsg
hi def link nvlime_mreplWarning WarningMsg
hi def link nvlime_mreplError ErrorMsg

let b:current_syntax = 'nvlime_mrepl'

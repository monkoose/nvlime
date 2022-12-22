if exists('b:current_syntax')
    finish
endif

syntax match nvlime_docParagraph "\m\c^\s*\%(function\|arglist\|variable\):"
syntax match nvlime_docTitle "\m\c^\s*documentation for the symbol .*:$" contains=nvlime_docSymbol
syntax match nvlime_docMiss "\m\c^\s*no such symbol, .*\.$" contains=nvlime_docSymbol
syntax match nvlime_docSymbol "\m\cfor the symbol \zs.*\ze:$" contained
syntax match nvlime_docSymbol "\m\csuch symbol, \zs.*\ze\.$" contained

hi def link nvlime_docParagraph Special
hi def link nvlime_docTitle Comment
hi def link nvlime_docMiss Normal
hi def link nvlime_docSymbol Statement

let b:current_syntax = 'nvlime_documentation'

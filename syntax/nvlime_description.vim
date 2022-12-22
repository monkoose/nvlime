if exists('b:current_syntax')
    finish
endif

syntax match nvlime_descriptionPath "\m\c^\s*source file:.*$" contains=nvlime_descriptionParagraph
syntax match nvlime_descriptionParagraph "\m\c^\s*\%(lambda-list\|documentation\|declared type\|derived type\):"
syntax match nvlime_descriptionParagraph "\m\c^\s*\%(class precedence-list\|direct superclasses\|assumed type\):"
syntax match nvlime_descriptionParagraph "\m\c^\s*\%(source form\):"
syntax match nvlime_descriptionParagraph "\m\c^\s*\%(known attributes\|value\|dynamic-extent arguments\|Inline proclamation\):"
syntax match nvlime_descriptionParagraph "\m\c^\s*source file:" contained

syntax match nvlime_descriptionName "\m\c^.\{-1,} names \%(an\?\|the\) .\{-1,}$" contains=nvlime_descriptionSymbol,nvlime_descriptionItem
syntax match nvlime_descriptionSymbol "\m\c^.*\ze names \%(an\?\|the\)" contained
syntax match nvlime_descriptionSymbol "\m\c^.*\ze has" contained
syntax match nvlime_descriptionItem "\m\cnames an \zsundefined function$" contained
syntax match nvlime_descriptionItem "\m\cnames \%(an\?\|the\) \zs.*\ze:$" contained
syntax match nvlime_descriptionItem "\m\csetf-expansion:\zs.*\ze$" contained

syntax match nvlime_descriptionName "\m\c^.* has.*setf-expansion:.*$" contains=nvlime_descriptionSymbol,nvlime_descriptionItem

hi def link nvlime_descriptionParagraph Special
hi def link nvlime_descriptionPath Function
hi def link nvlime_descriptionSymbol Statement
hi def link nvlime_descriptionItem String
hi def link nvlime_descriptionName Normal

let b:current_syntax = 'nvlime_description'

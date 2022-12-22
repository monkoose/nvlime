if exists('b:current_syntax')
    finish
endif

syntax match nvlime_notesError "\m\c^\s*\%(read-\)\?error:"
syntax match nvlime_notesWarn "\m\c^\s*warning:"
syntax match nvlime_notesInfo "\m\c^\s*\%(redefinition\|style-warning\):"
syntax match nvlime_notesInfo "\m\c^\s*\%(early-deprecation-warning\|late-deprecation-warning\|final-deprecation-warning\):"
syntax match nvlime_notesHint "\m\c^\s*note:"

hi def link nvlime_notesError DiagnosticError
hi def link nvlime_notesWarn DiagnosticWarn
hi def link nvlime_notesInfo DiagnosticInfo
hi def link nvlime_notesHint DiagnosticHint

let b:current_syntax = 'nvlime_notes'

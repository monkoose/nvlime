if exists('b:current_syntax')
    finish
endif

syntax match nvlime_disassemblyLine "\m\%>3l.*" contains=nvlime_disassemblyComment,nvlime_disassemblyLabel,
      \ nvlime_disassemblyAddress,@CodeInstruction
syntax match nvlime_disassemblyAddress "\m\%>3l^\s*[[:xdigit:]]\+\ze:\s" contained
syntax match nvlime_disassemblyLabel "\m\%>3l:\s\+\zsL\d*\ze:\s" contained
syntax match nvlime_disassemblyInstruction "\m\%>3l:\zs\s\+[[:xdigit:]]\+\s\+\S\+\%(\s\|$\)" contained contains=nvlime_disassemblyAsmInstruction
syntax match nvlime_disassemblyAsmInstruction "\m\%>3l\s\+[[:xdigit:]]\+\s\+\zs\S\+\ze\%(\s\|$\)" contained
syntax cluster CodeInstruction contains=nvlime_disassemblyInstruction,nvlime_disassemblyAsmInstruction

syntax match nvlime_disassemblyComment "\m\s\zs;\s.\{-}$" contained
syntax match nvlime_disassemblyComment "\m\s\zs;\s.\{-}$"

syntax match nvlime_disassemblyBold "\m\%2lSize:\s\d\+" contains=nvlime_disassemblySize
syntax match nvlime_disassemblySize "\m\%2l\d\+" contained

syntax match nvlime_disassemblyBold "\m\%2lOrigin:\s#x[[:xdigit:]]\+" contains=nvlime_disassemblyAddress
syntax match nvlime_disassemblyAddress "\m\%2l#x[[:xdigit:]]\+" contained

syntax match nvlime_disassemblySymbol "\m\%1ldisassembly\sfor\s\zs.*"

hi def link nvlime_disassemblyAddress Constant
hi def link nvlime_disassemblySize Constant
hi def link nvlime_disassemblyComment Comment
hi def link nvlime_disassemblySymbol Statement
hi def link nvlime_disassemblySymbol Statement
hi def link nvlime_disassemblyLabel Statement
hi def link nvlime_disassemblyInstruction Identifier
hi def link nvlime_disassemblyLine String
hi def nvlime_disassemblyBold cterm=bold gui=bold
hi def link nvlime_disassemblyAsmInstruction nvlime_disassemblyBold

let b:current_syntax = 'nvlime_disassembly'

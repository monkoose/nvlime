if exists('b:current_syntax')
    finish
endif

syntax match nvlime_threadsID "\m^\s*\d\+"
syntax match nvlime_threadsRunning "\m\CRunning\s*$"
syntax match nvlime_threadsTitle "\m\C\%1l\%(ID\|NAME\|STATUS\)"

hi def link nvlime_threadsID Constant
hi def link nvlime_threadsRunning String
hi def nvlime_threadsTitle cterm=bold gui=bold

let b:current_syntax = 'nvlime_threads'

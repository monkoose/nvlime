local km_globals = require("nvlime.keymaps.globals")
local km_trace = require("nvlime.keymaps.trace")
km_globals.add(true, true)
return km_trace.add()
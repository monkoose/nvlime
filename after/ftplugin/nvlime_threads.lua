local km_globals = require("nvlime.keymaps.globals")
local km_threads = require("nvlime.keymaps.threads")
km_globals.add(true, true)
return km_threads.add()
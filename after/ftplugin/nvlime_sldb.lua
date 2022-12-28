local km_globals = require("nvlime.keymaps.globals")
local km_sldb = require("nvlime.keymaps.sldb")
km_globals.add(false, false)
return km_sldb.add()
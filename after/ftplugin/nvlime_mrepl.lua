local km_globals = require("nvlime.keymaps.globals")
local km_mrepl = require("nvlime.keymaps.mrepl")
km_globals.add(true, true)
return km_mrepl.add()
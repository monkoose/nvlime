local km_globals = require("nvlime.keymaps.globals")
local km_inspector = require("nvlime.keymaps.inspector")
km_globals.add(true, true)
return km_inspector.add()
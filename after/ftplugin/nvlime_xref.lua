local km_globals = require("nvlime.keymaps.globals")
local km_xref = require("nvlime.keymaps.xref")
km_globals.add(true, true)
return km_xref.add()
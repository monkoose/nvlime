local km_globals = require("nvlime.keymaps.globals")
local km_apropos = require("nvlime.keymaps.apropos")
km_globals.add(true, true)
return km_apropos.add()
local km_globals = require("nvlime.keymaps.globals")
local km_server = require("nvlime.keymaps.server")
km_globals.add(true, true)
return km_server.add()
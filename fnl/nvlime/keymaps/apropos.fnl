(local km (require "nvlime.keymaps"))
(local am km.mappings.apropos)

(local apropos {})

(fn apropos.add []
  (km.buffer.normal am.normal.inspect
                    "<Cmd>call nvlime#plugin#Inspect(\"'\" .. substitute(getline('.'), '  .*$', '', ''))<CR>"
                    "nvlime: Inspect current symbol"))

apropos

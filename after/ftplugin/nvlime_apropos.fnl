(local km (require "nvlime.keymaps"))
(local km-globals (require "nvlime.keymaps.globals"))


(when (not (or vim.g.nvlime_disable_inspector_mappings vim.g.nvlime_disable_mappings))
  (when (not vim.g.nvlime_disable_global_mappings)
    (km-globals.add true true))
  (km.buffer.normal "i"
                 "<Cmd>call nvlime#plugin#Inspect(\"'\" .. substitute(getline('.'), '  .*$', '', ''))<CR>"
                 "nvlime: Inspect current symbol"))

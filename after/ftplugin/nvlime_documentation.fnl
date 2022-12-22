(local km-globals (require "nvlime.keymaps.globals"))

(when (not vim.g.nvlime_disable_mappings)
  (when (not vim.g.nvlime_disable_global_mappings)
    (km-globals.add true true)))

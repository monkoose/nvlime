(when vim.g.nvlime_enable_cmp
  (local cmp (require "cmp"))
  (cmp.register_source "nvlime" (require "nvlime.cmp")))

(local opts (require "nvlime.config"))

(when opts.cmp.enabled
  (local cmp (require "cmp"))
  (cmp.register_source "nvlime" (require "nvlime.cmp")))

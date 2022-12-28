local opts = require("nvlime.config")
if opts.cmp.enabled then
  local cmp = require("cmp")
  return cmp.register_source("nvlime", require("nvlime.cmp"))
else
  return nil
end
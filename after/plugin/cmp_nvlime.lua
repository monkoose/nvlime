if vim.g.nvlime_enable_cmp then
  local cmp = require("cmp")
  return cmp.register_source("nvlime", require("nvlime.cmp"))
else
  return nil
end
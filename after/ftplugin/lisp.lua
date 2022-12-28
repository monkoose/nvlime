local km_globals = require("nvlime.keymaps.globals")
local km_input = require("nvlime.keymaps.input")
local km_lisp = require("nvlime.keymaps.lisp")
vim.api.nvim_buf_set_option(0, "lisp", false)
vim.cmd("syntax match SpellIgnore /\\<u\\+\\>/ contains=@NoSpell")
if vim.b.nvlime_input then
  km_globals.add(true, true)
  return km_input.add()
else
  km_globals.add(false, false)
  return km_lisp.add()
end
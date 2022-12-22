local keymaps = {leader = (vim.g.nvlime_leader or "<LocalLeader>"), buffer = {}}
local function from_keycode(key)
  return vim.api.nvim_replace_termcodes(key, true, false, true)
end
keymaps.feedkeys = function(keys)
  return vim.api.nvim_feedkeys(from_keycode(keys), "n", false)
end
local function set_buf_map(mode, lhs, rhs, desc)
  local opts = {noremap = true, nowait = true, silent = true, desc = desc}
  if (type(rhs) == "function") then
    opts["callback"] = rhs
    return vim.api.nvim_buf_set_keymap(0, mode, lhs, "", opts)
  else
    return vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, opts)
  end
end
keymaps.buffer.normal = function(lhs, rhs, desc)
  return set_buf_map("n", lhs, rhs, desc)
end
keymaps.buffer.insert = function(lhs, rhs, desc)
  return set_buf_map("i", lhs, rhs, desc)
end
keymaps.buffer.visual = function(lhs, rhs, desc)
  return set_buf_map("v", lhs, rhs, desc)
end
keymaps.buffer.get = function()
  local maps = {}
  for _, mode in ipairs({"n", "i", "v"}) do
    local tbl_17_auto = maps
    local i_18_auto = #tbl_17_auto
    for _0, map in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
      local val_19_auto
      if (map.desc and string.find(map.desc, "^nvlime:")) then
        val_19_auto = {mode = map.mode, lhs = string.gsub(map.lhs, " ", "<SPACE>"), desc = string.gsub(map.desc, "^nvlime: ", "")}
      else
        val_19_auto = nil
      end
      if (nil ~= val_19_auto) then
        i_18_auto = (i_18_auto + 1)
        do end (tbl_17_auto)[i_18_auto] = val_19_auto
      else
      end
    end
  end
  return maps
end
return keymaps
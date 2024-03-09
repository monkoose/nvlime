local window = require("nvlime.window")
local pwin = require("parsley.window")
local opts = require("nvlime.config")
local ut = require("nvlime.utilities")
local _local_1_ = vim.api
local nvim_exec = _local_1_["nvim_exec"]
local nvim_win_set_buf = _local_1_["nvim_win_set_buf"]
local nvim_set_current_win = _local_1_["nvim_set_current_win"]
local nvim_get_current_win = _local_1_["nvim_get_current_win"]
local nvim_buf_get_name = _local_1_["nvim_buf_get_name"]
local nvim_win_get_buf = _local_1_["nvim_win_get_buf"]
local nvim_win_set_option = _local_1_["nvim_win_set_option"]
local main_win_pos
do
  local _2_ = opts.main_window.position
  if (_2_ == "top") then
    main_win_pos = "topleft"
  elseif (_2_ == "left") then
    main_win_pos = "vertical topleft"
  elseif (_2_ == "bottom") then
    main_win_pos = "botright"
  elseif (_2_ == "right") then
    main_win_pos = "vertical botright"
  else
    local _ = _2_
    main_win_pos = "vertical botright"
  end
end
local main_win = {pos = main_win_pos, size = opts.main_window.size, ["vert?"] = (nil ~= (main_win_pos and string.find(main_win_pos, "^vertical")))}
main_win.init = function(self, cmd, size, opposite)
  local vert_3f = main_win["vert?"]
  self["id"] = nil
  self["buffers"] = {}
  local _4_
  if vert_3f then
    _4_ = cmd
  else
    _4_ = ("vertical " .. cmd)
  end
  self["cmd"] = _4_
  local _6_
  if vert_3f then
    _6_ = size
  else
    _6_ = nil
  end
  self["size"] = _6_
  self["opposite"] = opposite
  return self
end
main_win.new = function(...)
  local self = setmetatable({}, {__index = main_win})
  self:init(...)
  return self
end
local repl_win = {}
setmetatable(repl_win, {__index = main_win})
repl_win.new = function(...)
  local self = setmetatable({}, {__index = repl_win})
  self:init(...)
  return self
end
do
  local sldb_height = 0.65
  main_win["sldb"] = main_win.new("", sldb_height, "repl")
  do end (main_win)["repl"] = repl_win.new("leftabove", (1 - sldb_height), "sldb")
end
main_win["set-id"] = function(self, winid)
  self["id"] = winid
  return nil
end
main_win["set-options"] = function(self)
  window["set-minimal-style-options"](self.id)
  nvim_win_set_option(self.id, "foldcolumn", "1")
  return nvim_win_set_option(self.id, "winhighlight", "FoldColumn:Normal")
end
main_win["remove-buf"] = function(self, bufnr)
  for i, b in ipairs(self.buffers) do
    if (b == bufnr) then
      table.remove(self.buffers, i)
    else
    end
  end
  return nil
end
main_win["add-buf"] = function(self, bufnr)
  self["remove-buf"](self, bufnr)
  return table.insert(self.buffers, bufnr)
end
main_win["update-opts"] = function(self)
  local winid = nvim_get_current_win()
  self["set-id"](self, winid)
  self["add-buf"](self, nvim_win_get_buf(winid))
  return self["set-options"](self)
end
main_win["split-opposite"] = function(self, bufnr)
  local opposite = main_win[self.opposite]
  nvim_set_current_win(opposite.id)
  local height
  if (self.size and (type(self.size) == "number")) then
    height = math.floor((pwin["get-height"](opposite.id) * self.size))
  else
    height = ""
  end
  nvim_exec((self.cmd .. " " .. height .. "split " .. nvim_buf_get_name(bufnr)), false)
  return self["update-opts"](self)
end
main_win.split = function(self, bufnr)
  local bufname = nvim_buf_get_name(bufnr)
  nvim_exec((main_win.pos .. " " .. main_win.size .. "split " .. bufname), false)
  return self["update-opts"](self)
end
main_win["open-new"] = function(self, bufnr, focus_3f)
  local prev_winid = nvim_get_current_win()
  local opposite = main_win[self.opposite]
  if pwin["visible?"](opposite.id) then
    self["split-opposite"](self, bufnr)
  else
    self:split(bufnr)
  end
  if not focus_3f then
    return nvim_set_current_win(prev_winid)
  else
    return nil
  end
end
main_win["show-buf"] = function(self, bufnr, focus_3f)
  if (nvim_win_get_buf(self.id) ~= bufnr) then
    nvim_win_set_buf(self.id, bufnr)
    self["add-buf"](self, bufnr)
  else
  end
  if focus_3f then
    return nvim_set_current_win(self.id)
  else
    return nil
  end
end
main_win.open = function(self, bufnr, focus_3f)
  if pwin["visible?"](self.id) then
    self["show-buf"](self, bufnr, focus_3f)
  else
    self["open-new"](self, bufnr, focus_3f)
  end
  return self.id
end
repl_win.open = function(self, bufnr, focus_3f)
  do
    local winid = ut["find-if"](pwin["visible?"], vim.fn.win_findbuf(bufnr))
    if winid then
      self["show-win"](self, winid, focus_3f)
    else
      self["open-new"](self, bufnr, focus_3f)
    end
  end
  return self.id
end
repl_win["show-win"] = function(self, winid, focus_3f)
  local prev_winid = nvim_get_current_win()
  nvim_set_current_win(winid)
  self["update-opts"](self)
  if not focus_3f then
    return nvim_set_current_win(prev_winid)
  else
    return nil
  end
end
return main_win
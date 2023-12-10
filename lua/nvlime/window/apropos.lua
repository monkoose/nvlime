local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local apropos = {}
local _2bbufname_2b = buffer["gen-name"](buffer.names.apropos)
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.apropos)
local function content__3elines(content)
  local lines = {}
  for _, item in ipairs(content) do
    local name
    do
      local t_1_ = item
      if (nil ~= t_1_) then
        t_1_ = t_1_[1]
      else
      end
      if (nil ~= t_1_) then
        t_1_ = t_1_.name
      else
      end
      name = t_1_
    end
    if ((name == "DESIGNATOR") or (name == "designator")) then
      local _end
      do
        local _4_
        do
          local t_5_ = item
          if (nil ~= t_5_) then
            t_5_ = t_5_[3]
          else
          end
          if (nil ~= t_5_) then
            t_5_ = t_5_.name
          else
          end
          _4_ = t_5_
        end
        if (_4_ == nil) then
          _end = ""
        elseif (nil ~= _4_) then
          local str = _4_
          _end = ("  " .. string.lower(str))
        else
          _end = nil
        end
      end
      table.insert(lines, (item[2] .. _end))
    else
    end
  end
  return lines
end
local function win_callback(winid)
  return window["set-opts"](winid, {cursorline = true})
end
apropos.open = function(content)
  local lines = content__3elines(content)
  local bufnr = buffer["create-scratch-with-conn-var!"](_2bbufname_2b, _2bfiletype_2b)
  local function _10_(_241)
    return win_callback(_241)
  end
  return {window.center.open(bufnr, lines, {height = 10, width = 60, title = buffer.names.apropos}, _10_), bufnr}
end
return apropos
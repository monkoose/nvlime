local window = require("nvlime.window")
local buffer = require("nvlime.buffer")
local apropos = {}
local _2bname_2b = "apropos"
local _2bbufname_2b = buffer["gen-name"](_2bname_2b)
local _2bfiletype_2b = buffer["gen-filetype"](_2bname_2b)
local function content__3elines(content)
  local lines = {}
  for _, item in ipairs(content) do
    local _2_
    do
      local t_1_ = item
      if (nil ~= t_1_) then
        t_1_ = (t_1_)[1]
      else
      end
      if (nil ~= t_1_) then
        t_1_ = (t_1_).name
      else
      end
      _2_ = t_1_
    end
    if (_2_ == "DESIGNATOR") then
      local _end
      do
        local _5_
        do
          local t_6_ = item
          if (nil ~= t_6_) then
            t_6_ = (t_6_)[3]
          else
          end
          if (nil ~= t_6_) then
            t_6_ = (t_6_).name
          else
          end
          _5_ = t_6_
        end
        if (_5_ == nil) then
          _end = ""
        elseif (nil ~= _5_) then
          local str = _5_
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
  local function _11_(_241)
    return win_callback(_241)
  end
  return {window.center.open(bufnr, lines, {height = 10, width = 60, title = _2bname_2b}, _11_), bufnr}
end
return apropos
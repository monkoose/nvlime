local buffer = require("nvlime.buffer")
local window = require("nvlime.window")
local ut = require("nvlime.utilities")
local psl = require("parsley")
local psl_list = require("parsley.list")
local inspector = {}
local _2bbufname_2b = buffer["gen-name"](buffer.names.inspector)
local _2bfiletype_2b = buffer["gen-filetype"](buffer.names.inspector)
local _2bnamespace_2b = vim.api.nvim_create_namespace(_2bfiletype_2b)
local _2acontent_title_2a = ""
local _2acoords_2a = {}
local _2acontent_start_2a = 0
local _2acontent_end_2a = 0
local function make_range_buttons(content)
  local buttons = {}
  local add_separator
  local function _1_()
    return table.insert(buttons, "  ")
  end
  add_separator = _1_
  local add_newline
  local function _2_()
    return table.insert(buttons, "\n")
  end
  add_newline = _2_
  local add_button
  local function _3_(name, id)
    return table.insert(buttons, {{name = "RANGE", package = "KEYWORD"}, name, id})
  end
  add_button = _3_
  _2acontent_start_2a = content[3]
  _2acontent_end_2a = content[4]
  if (_2acontent_start_2a > 0) then
    add_newline()
    add_button("[prev range]", -1)
  else
  end
  if (content[2] > _2acontent_end_2a) then
    if psl["empty?"](buttons) then
      add_newline()
    else
      add_separator()
    end
    add_button("[next range]", 1)
  else
  end
  if not psl["empty?"](buttons) then
    add_separator()
    add_button("[all content]", 0)
    table.insert(buttons, "\n")
  else
  end
  return buttons
end
local function content__3elines_2a(content)
  local lines = {}
  local line = ""
  local get_cur_pos
  local function _8_()
    return {(#lines + 1), (#line + 1)}
  end
  get_cur_pos = _8_
  local function add_lines(c)
    if psl["string?"](c) then
      if (c == "\n") then
        local splitted_line = vim.split(line, "\n")
        do
          local tbl_17_auto = lines
          local i_18_auto = #tbl_17_auto
          for _, l in ipairs(splitted_line) do
            local val_19_auto = l
            if (nil ~= val_19_auto) then
              i_18_auto = (i_18_auto + 1)
              do end (tbl_17_auto)[i_18_auto] = val_19_auto
            else
            end
          end
        end
        line = ""
        return nil
      else
        line = (line .. c)
        return nil
      end
    elseif psl["list?"](c) then
      if ((#c == 3) and psl["hash-table?"](c[1])) then
        local start = get_cur_pos()
        add_lines(c[2])
        return table.insert(_2acoords_2a, {id = c[3], type = c[1].name, begin = start, ["end"] = get_cur_pos()})
      else
        for _, i in ipairs(c) do
          add_lines(i)
        end
        return nil
      end
    else
      return nil
    end
  end
  add_lines(content)
  return lines
end
local function add_coords_highlight(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, _2bnamespace_2b, 0, 1)
  local set_extmark
  local function _13_(begin, _end, hl)
    return vim.api.nvim_buf_set_extmark(bufnr, _2bnamespace_2b, (begin[1] - 1), (begin[2] - 1), {end_row = (_end[1] - 1), end_col = (_end[2] - 1), hl_group = hl})
  end
  set_extmark = _13_
  for _, coord in ipairs(_2acoords_2a) do
    local _14_ = coord.type
    if (_14_ == "ACTION") then
      set_extmark(coord.begin, coord["end"], "nvlime_inspectorAction")
    elseif (_14_ == "VALUE") then
      set_extmark(coord.begin, coord["end"], "nvlime_inspectorValue")
    elseif (_14_ == "RANGE") then
      set_extmark(coord.begin, coord["end"], "nvlime_inspectorAction")
    else
    end
  end
  return nil
end
local function content__3elines(content)
  local content_2a = ut["plist->table"](content)
  local content_data = (content_2a).CONTENT
  local title = {(content_2a).TITLE, "\n", "\n"}
  local range_buttons = make_range_buttons(content_data)
  local lines = content__3elines_2a(psl_list.concat(title, content_data[1], range_buttons))
  _2acontent_title_2a = (content_2a).TITLE
  return lines
end
local function buf_callback(bufnr)
  buffer["set-opts"](bufnr, {bufhidden = "wipe", filetype = _2bfiletype_2b})
  return buffer["set-conn-var!"](bufnr)
end
inspector.open = function(content)
  _2acoords_2a = {}
  local lines = content__3elines(content)
  local bufnr
  local function _16_(_241)
    return buf_callback(_241)
  end
  bufnr = buffer["create-if-not-exists"](_2bbufname_2b, false, _16_)
  local winid = window.center.open(bufnr, lines, {height = 12, width = 80, title = buffer.names.inspector})
  add_coords_highlight(bufnr)
  buffer["set-vars"](bufnr, {nvlime_inspector_title = _2acontent_title_2a, nvlime_inspector_coords = _2acoords_2a, nvlime_inspector_content_start = _2acontent_start_2a, nvlime_inspector_content_end = _2acontent_end_2a})
  return {winid, bufnr}
end
return inspector
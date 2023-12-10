local buffer = require("nvlime.buffer")
local psl = require("parsley")
local psl_buf = require("parsley.buffer")
local presentation = {coords = {}, namespace = vim.api.nvim_create_namespace("nvlime_presentations")}
local _2arepl_bufnr_2a = nil
local _2apending_coords_2a = {}
local function set_presentation_begin(bufnr, msg)
  local last_linenr = vim.api.nvim_buf_line_count(bufnr)
  local id = psl.second(msg)
  local coords_list = (_2apending_coords_2a[id] or {})
  table.insert(coords_list, {begin = {(last_linenr + 1), 1}, type = "PRESENTATION", id = id})
  do end (_2apending_coords_2a)[id] = coords_list
  return nil
end
local function set_presentation_end(bufnr, coord)
  local last_linenr = vim.api.nvim_buf_line_count(bufnr)
  local last_col = psl_buf["line-length"](bufnr, last_linenr)
  do end (coord)["end"] = {last_linenr, last_col}
  return nil
end
local function get_pending_coord(coords_list)
  local index = 0
  local pending_coord = nil
  for i, coord in ipairs(coords_list) do
    if pending_coord then break end
    if not coord["end"] then
      index = i
      pending_coord = coord
    else
    end
  end
  if pending_coord then
    return pending_coord, index
  else
    return nil
  end
end
local function highlight_presentation(bufnr, coord)
  local begin = coord.begin
  local _end = coord["end"]
  local function _3_()
    return vim.api.nvim_buf_set_extmark(bufnr, presentation.namespace, (psl.first(begin) - 1), (psl.second(begin) - 1), {end_row = (psl.first(_end) - 1), end_col = psl.second(_end), hl_group = "nvlime_replCoord"})
  end
  return vim.defer_fn(_3_, 3)
end
presentation.on_start = function(conn, msg)
  local _, repl_bufnr = psl_buf["exists?"](buffer["gen-repl-name"](conn.cb_data.name))
  _2arepl_bufnr_2a = repl_bufnr
  if _2arepl_bufnr_2a then
    return set_presentation_begin(repl_bufnr, msg)
  else
    return nil
  end
end
presentation.on_end = function(_, msg)
  if _2arepl_bufnr_2a then
    local id = psl.second(msg)
    local coords_list = (_2apending_coords_2a[id] or {})
    local pending_coord, idx = get_pending_coord(coords_list)
    if pending_coord then
      set_presentation_end(_2arepl_bufnr_2a, pending_coord)
      table.remove(coords_list, idx)
      if (#coords_list <= 0) then
        _2apending_coords_2a[id] = nil
      else
      end
      do
        local startline = pending_coord.begin[1]
        presentation.coords[startline] = pending_coord
      end
      highlight_presentation(_2arepl_bufnr_2a, pending_coord)
    else
    end
  else
  end
  return nil
end
return presentation
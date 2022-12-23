local buffer = require("nvlime.buffer")
local psl = require("parsley")
local psl_buf = require("parsley.buffer")
local presentation = {["pending-coords"] = {}, namespace = vim.api.nvim_create_namespace("nvlime_presentations")}
local _2arepl_bufnr_2a = nil
local function set_presentation_begin(bufnr, msg)
  local last_linenr = vim.api.nvim_buf_line_count(bufnr)
  local id = psl.second(msg)
  local coords_list = ((presentation["pending-coords"])[id] or {})
  table.insert(coords_list, {begin = {last_linenr, 1}, type = "PRESENTATION", id = id})
  do end (presentation["pending-coords"])[id] = coords_list
  return nil
end
local function set_presentation_end(bufnr, coord)
  local last_linenr = vim.api.nvim_buf_line_count(bufnr)
  local last_col = psl_buf["line-length"](bufnr, last_linenr)
  do end (coord)["end"] = {last_linenr, last_col}
  return nil
end
local function get_pending_coord(coords_list)
  for i, coord in ipairs(coords_list) do
    if not coord["end"] then
      return coord, i
    else
    end
  end
  return nil
end
local function highlight_presentation(bufnr, coord)
  local begin = coord.begin
  local _end = coord["end"]
  local function _2_()
    return vim.api.nvim_buf_set_extmark(bufnr, presentation.namespace, (psl.first(begin) - 1), (psl.second(begin) - 1), {end_row = (psl.first(_end) - 1), end_col = psl.second(_end), hl_group = "nvlime_replCoord"})
  end
  return vim.defer_fn(_2_, 3)
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
    local coords_list = ((presentation["pending-coords"])[id] or {})
    local pending_coord, idx = get_pending_coord(coords_list)
    if pending_coord then
      set_presentation_end(_2arepl_bufnr_2a, pending_coord)
      table.remove(coords_list, idx)
      if (#coords_list <= 0) then
        presentation["pending-coords"][id] = nil
      else
      end
      do
        local repl_coords = psl_buf["get-var!"](_2arepl_bufnr_2a, "nvlime_repl_coords", {})
        table.insert(repl_coords, pending_coord)
        buffer["set-vars"](_2arepl_bufnr_2a, {nvlime_repl_coords = repl_coords})
      end
      highlight_presentation(_2arepl_bufnr_2a, pending_coord)
    else
    end
  else
  end
  return nil
end
return presentation
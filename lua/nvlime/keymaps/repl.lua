local km = require("nvlime.keymaps")
local rm = km.mappings.repl
local buffer = require("nvlime.buffer")
local presentations = require("nvlime.contrib.presentations")
local repl_win = require("nvlime.window.main.repl")
local ut = require("nvlime.utilities")
local _local_1_ = vim.api
local nvim_buf_line_count = _local_1_["nvim_buf_line_count"]
local repl = {}
local function prev_or_current_coord(coords, linenr)
  if (linenr > 0) then
    local coord = coords[linenr]
    if coord then
      return coord
    else
      return prev_or_current_coord(coords, (linenr - 1))
    end
  else
    return nil
  end
end
local function prev_coord(coords, linenr, col)
  local coord = prev_or_current_coord(coords, linenr)
  if (coord and ut["in-coord-range?"](coord, linenr, col)) then
    return prev_or_current_coord(coords, (coord.begin[1] - 1))
  else
    return coord
  end
end
local function next_coord(coords, linenr, max_linenr)
  local lnr = (linenr + 1)
  if (max_linenr >= lnr) then
    local coord = coords[lnr]
    if coord then
      return coord
    else
      return next_coord(coords, lnr, max_linenr)
    end
  else
    return nil
  end
end
local function jump_to_coord(backward_3f)
  local _let_7_ = ut["get-win-cursor"](0)
  local linenr = _let_7_[1]
  local col = _let_7_[2]
  local jump
  local function _8_(coord)
    if coord then
      return ut["set-win-cursor"](0, {coord.begin[1], coord.begin[2]})
    else
      return ut.echo("No more presented objects.")
    end
  end
  jump = _8_
  if backward_3f then
    return jump(prev_coord(presentations.coords, linenr, col))
  else
    local max_linenr = nvim_buf_line_count(0)
    return jump(next_coord(presentations.coords, linenr, max_linenr))
  end
end
local function find_coord(coords, linenr, col)
  local coord = prev_or_current_coord(coords, linenr)
  if (coord and ut["in-coord-range?"](coord, linenr, col)) then
    return coord
  else
    return nil
  end
end
local function do_cur_presentation(func)
  if not vim.tbl_contains(vim.b.nvlime_conn.cb_data.contribs, "SWANK-PRESENTATIONS") then
    return ut["echo-error"]("SWANK-PRESENTATIONS is not available.")
  else
    local _let_12_ = ut["get-win-cursor"](0)
    local linenr = _let_12_[1]
    local col = _let_12_[2]
    local coord = find_coord(presentations.coords, linenr, col, true)
    if (coord and (coord.type == "PRESENTATION")) then
      return func(coord)
    else
      return ut["echo-warning"]("Not on a presented object.")
    end
  end
end
local function yank_cur_presentation()
  local function _15_(coord)
    vim.fn.setreg("\"", ("(swank:lookup-presented-object " .. coord.id .. ")"))
    return ut.echo(("Presented object " .. coord.id .. " yanked."))
  end
  return do_cur_presentation(_15_)
end
local function inspect_cur_presentation()
  local function _16_(coord)
    return buffer["vim-call!"](0, {("call b:nvlime_conn.InspectPresentation(" .. coord.id .. ", v:true, " .. "{c, r -> c.ui.OnInspect(c, r, v:null, v:null)})")})
  end
  return do_cur_presentation(_16_)
end
repl.add = function()
  km.buffer.normal(rm.normal.interrupt, "<Cmd>call b:nvlime_conn.Interrupt({'name': 'REPL-THREAD', 'package': 'KEYWORD'})<CR>", "nvlime: Interrupt the REPL thread")
  local function _17_()
    return repl_win.clear()
  end
  km.buffer.normal(rm.normal.clear, _17_, "nvlime: Clear the REPL buffer")
  km.buffer.normal(rm.normal.inspect_result, inspect_cur_presentation, "nvlime: Insect the evaluation result under the cursor")
  km.buffer.normal(rm.normal.yank_result, yank_cur_presentation, "nvlime: Yank the evaluation result under the cursor")
  local function _18_()
    return jump_to_coord()
  end
  km.buffer.normal(rm.normal.next_result, _18_, "nvlime: Move the cursor to the next presented object")
  local function _19_()
    return jump_to_coord(true)
  end
  return km.buffer.normal(rm.normal.prev_result, _19_, "nvlime: Move the cursor to the next presented object")
end
return repl
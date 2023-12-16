local opts = require("nvlime.config")
local psl = require("parsley")
local _local_1_ = vim.api
local nvim_replace_termcodes = _local_1_["nvim_replace_termcodes"]
local nvim_feedkeys = _local_1_["nvim_feedkeys"]
local nvim_buf_set_keymap = _local_1_["nvim_buf_set_keymap"]
local nvim_buf_get_keymap = _local_1_["nvim_buf_get_keymap"]
local keymaps = {leader = opts.leader, buffer = {}}
local function with_leader(key)
  return (opts.leader .. key)
end
local global_mappings = {normal = {close_current_window = "q", keymaps_help = {"<F1>", with_leader("?")}, close_nvlime_windows = with_leader("ww"), close_floating_window = "<Esc>", scroll_up = "<C-p>", scroll_down = "<C-n>", split_left = "<C-w>h", split_right = "<C-w>l", split_above = "<C-w>k", split_below = "<C-w>j"}}
local lisp_mappings = {normal = {interaction_mode = with_leader("<CR>"), load_file = with_leader("l"), disassemble = {expr = with_leader("aa"), symbol = with_leader("as")}, set_package = with_leader("p"), set_breakpoint = with_leader("b"), show_threads = with_leader("T"), connection = {new = with_leader("cc"), switch = with_leader("cs"), rename = with_leader("cR"), close = with_leader("cd")}, server = {new = with_leader("rr"), show = with_leader("rv"), show_selected = with_leader("rV"), stop = with_leader("rs"), stop_selected = with_leader("rS"), rename = with_leader("rR"), restart = with_leader("rt")}, repl = {show = with_leader("so"), clear = with_leader("sC"), send_atom_expr = with_leader("ss"), send_atom = with_leader("sa"), send_expr = with_leader("se"), send_toplevel_expr = with_leader("st"), prompt = with_leader("si")}, macro = {expand = with_leader("mm"), expand_once = with_leader("mo"), expand_all = with_leader("ma")}, compile = {expr = with_leader("ce"), toplevel_expr = with_leader("ct"), file = with_leader("cf")}, xref = {["function"] = {callers = with_leader("xc"), callees = with_leader("xC")}, symbol = {references = with_leader("xr"), bindings = with_leader("xb"), definition = with_leader("xd"), set_locations = with_leader("xs")}, macro = {callers = with_leader("xe")}, class = {methods = with_leader("xm")}, prompt = with_leader("xi")}, describe = {operator = with_leader("do"), atom = with_leader("da"), prompt = with_leader("di")}, apropos = {prompt = with_leader("ds")}, arglist = {show = with_leader("dr")}, documentation = {operator = with_leader("ddo"), atom = {"K", with_leader("dda")}, prompt = with_leader("ddi")}, inspect = {atom_expr = with_leader("ii"), atom = with_leader("ia"), expr = with_leader("ie"), toplevel_expr = with_leader("it"), symbol = with_leader("is"), prompt = with_leader("in")}, trace = {show = with_leader("td"), toggle = with_leader("tt"), prompt = with_leader("ti")}, undefine = {["function"] = with_leader("uf"), symbol = with_leader("us"), prompt = with_leader("ui")}}, insert = {space_arglist = "<Space>", cr_arglist = "<CR>"}, visual = {repl = {send_selection = with_leader("s")}, compile = {selection = with_leader("c")}, inspect = {selection = with_leader("i")}}}
local input_mappings = {normal = {complete = "<CR>"}, insert = {keymaps_help = "<F1>", complete = "<CR>", next_history = "<C-n>", prev_history = "<C-p>", leave_insert = "<Esc>"}}
local repl_mappings = {normal = {interrupt = "<C-c>", clear = "C", inspect_result = "i", yank_result = "y", next_result = {"<Tab>", "<C-n>"}, prev_result = {"<S-Tab>", "<C-p>"}}}
local sldb_mappings = {normal = {action = "<CR>", details = "d", frame = {toggle_details = "d", source = "S", source_split = "<C-s>", source_vsplit = "<C-v>", source_tab = "<C-t>", restart = "r", eval_expr = "e", send_expr = "E", disassemble = "D", return_result = "R", step = "s"}, local_var = {source = "O", inspect = "i"}, step_over = "x", step_out = "o", abort = "a", continue = "c", inspect_condition = "C"}}
local apropos_mappings = {normal = {inspect = "i"}}
local inspector_mappings = {normal = {action = "<CR>", current = {send = "s", source = "o"}, inspected = {send = "S", source = "O", previous = "<C-o>", next = "<C-i>"}, next_field = "<C-n>", prev_field = {"<S-Tab>", "<C-p>"}, refresh = "R"}}
local notes_mappings = {normal = {source = "<CR>", source_split = "<C-s>", source_vsplit = "<C-v>", source_tab = "<C-t>"}}
local server_mappings = {normal = {connect = with_leader("c"), stop = with_leader("s")}}
local threads_mappings = {normal = {interrupt = "<C-c>", kill = "K", invoke_debugger = "D", refresh = "r"}}
local trace_mappings = {normal = {action = "<CR>", refresh = "R", inspect_value = "i", send_value = "s", next_field = {"<Tab>", "<C-n>"}, prev_field = {"<S-Tab>", "<C-p>"}}}
local xref_mappings = {normal = {source = "<CR>", source_split = "<C-s>", source_vsplit = "<C-v>", source_tab = "<C-t>"}}
local mrepl_mappings = {normal = {clear = with_leader("C"), disconnect = with_leader("D")}, insert = {space_arglist = "<Space>", cr_arglist = "<C-j>", submit = "<CR>", interrupt = "<C-c>"}}
local default_mappings = {global = global_mappings, lisp = lisp_mappings, input = input_mappings, repl = repl_mappings, sldb = sldb_mappings, apropos = apropos_mappings, inspector = inspector_mappings, notes = notes_mappings, server = server_mappings, threads = threads_mappings, trace = trace_mappings, xref = xref_mappings, mrepl = mrepl_mappings}
keymaps["mappings"] = vim.tbl_deep_extend("force", default_mappings, (vim.g.nvlime_mappings or {}))
local function from_keycode(key)
  return nvim_replace_termcodes(key, true, false, true)
end
keymaps.feedkeys = function(keys)
  return nvim_feedkeys(from_keycode(keys), "n", false)
end
local function set_buf_map(mode, lhs, rhs, desc)
  local opts0 = {noremap = true, nowait = true, silent = true, desc = desc}
  if (type(rhs) == "function") then
    opts0["callback"] = rhs
    return nvim_buf_set_keymap(0, mode, lhs, "", opts0)
  else
    return nvim_buf_set_keymap(0, mode, lhs, rhs, opts0)
  end
end
local function set_buf_map_2a(mode, lhs, rhs, desc)
  if psl["string?"](lhs) then
    if (lhs ~= "") then
      return set_buf_map(mode, lhs, rhs, desc)
    else
      return nil
    end
  else
    for _, l in ipairs(lhs) do
      set_buf_map(mode, l, rhs, desc)
    end
    return nil
  end
end
keymaps.buffer.normal = function(lhs, rhs, desc)
  return set_buf_map_2a("n", lhs, rhs, desc)
end
keymaps.buffer.insert = function(lhs, rhs, desc)
  return set_buf_map_2a("i", lhs, rhs, desc)
end
keymaps.buffer.visual = function(lhs, rhs, desc)
  return set_buf_map_2a("v", lhs, rhs, desc)
end
keymaps.buffer.get = function()
  local maps = {}
  for _, mode in ipairs({"n", "i", "v"}) do
    local tbl_17_auto = maps
    for _0, map in ipairs(nvim_buf_get_keymap(0, mode)) do
      local function _5_()
        if (map.desc and string.find(map.desc, "^nvlime:")) then
          return {mode = map.mode, lhs = string.gsub(map.lhs, " ", "<SPACE>"), desc = string.gsub(map.desc, "^nvlime: ", "")}
        else
          return nil
        end
      end
      table.insert(tbl_17_auto, _5_())
    end
  end
  return maps
end
return keymaps
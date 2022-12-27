local config = {}
local default_indent_keywords = {defun = 2, defmacro = 2, defgeneric = 2, defmethod = 2, deftype = 2, lambda = 1, ["if"] = 3, unless = 1, when = 1, case = 1, ecase = 1, typecase = 1, etypecase = 1, ["eval-when"] = 1, let = 1, ["let*"] = 1, flet = 1, labels = 1, macrolet = 1, ["symbol-macrolet"] = 1, ["do"] = 2, ["do*"] = 2, ["do-all-symbols"] = 1, ["do-external-symbols"] = 1, ["do-symbols"] = 1, dolist = 1, dotimes = 1, ["destructuring-bind"] = 2, ["multiple-value-bind"] = 2, prog1 = 1, progv = 2, ["with-input-from-string"] = 1, ["with-output-to-string"] = 1, ["with-open-file"] = 1, ["with-open-stream"] = 1, ["with-package-iterator"] = 1, ["unwind-protect"] = 1, ["handler-bind"] = 1, ["handler-case"] = 1, ["restart-bind"] = 1, ["restart-case"] = 1, ["with-simple-restart"] = 1, ["with-slots"] = 2, ["with-accessors"] = 2, ["print-unreadable-object"] = 1, block = 1}
local default_contribs = {"SWANK-ARGLISTS", "SWANK-ASDF", "SWANK-C-P-C", "SWANK-FANCY-INSPECTOR", "SWANK-FUZZY", "SWANK-PACKAGE-FU", "SWANK-PRESENTATIONS", "SWANK-REPL"}
local default_leader
local function _1_(...)
  local t_2_ = vim.g
  if (nil ~= t_2_) then
    t_2_ = (t_2_).nvlime_config
  else
  end
  if (nil ~= t_2_) then
    t_2_ = (t_2_).leader
  else
  end
  return t_2_
end
default_leader = (_1_(...) or "<LocalLeader>")
local function with_leader(key)
  return (default_leader .. key)
end
local default_opts = {leader = default_leader, implementation = "sbcl", address = {host = "127.0.0.1", port = 7002}, connect_timeout = -1, compiler_policy = {}, indent_keywords = default_indent_keywords, input_history_limit = 100, contribs = default_contribs, user_contrib_initializers = {}, autodoc = {max_level = 5, max_lines = 50, enable = false}, main_window = {position = "right"}, floating_window = {border = "single", scroll_step = 3, scroll = {up = "<C-p>", down = "<C-n"}}, cmp = {enable = false}, arglist = {enable = true}}
config["options"] = vim.tbl_deep_extend("force", default_opts, (vim.g.nvlime_config or {}))
local global_mappings = {normal = {close_current_window = "q", keymaps_help = {"<F1>", with_leader("?")}, close_nvlime_windows = with_leader("ww"), close_floating_window = "<Esc>", scroll_up = "<C-p>", scroll_down = "<C-n>", split_left = "<C-w>h", split_right = "<C-w>l", split_above = "<C-w>k", split_below = "<C-w>j"}}
local input_mappings = {normal = {complete = "<CR>"}, insert = {keymaps_help = "<F1>", complete = "<CR>", prev_history = "<C-n>", next_history = "<C-p>", leave_insert = "<Esc>"}}
local repl_mappings = {normal = {interrupt = "<C-c>", clear = "C", inspect_result = "i", yank_result = "y", next_result = {"<Tab>", "<C-n>"}, prev_result = {"<S-Tab>", "<C-p>"}}}
local lisp_mappings = {normal = {interaction_mode = with_leader("<CR>"), load_file = with_leader("l"), disassemble = with_leader("a"), set_package = with_leader("p"), set_breakpoint = with_leader("b"), show_threads = with_leader("T"), connection = {new = with_leader("cc"), switch = with_leader("cs"), rename = with_leader("cR"), close = with_leader("cd")}, server = {new = with_leader("rr"), show = with_leader("rv"), show_selected = with_leader("rV"), stop = with_leader("rs"), stop_selected = with_leader("rS"), rename = with_leader("rR"), restart = with_leader("rt")}, repl = {show = with_leader("so"), clear = with_leader("sC"), send_atom_expr = with_leader("ss"), send_atom = with_leader("sa"), send_expr = with_leader("se"), send_toplevel_expr = with_leader("st"), prompt = with_leader("si")}, xref = {["function"] = {callers = with_leader("xc"), callees = with_leader("xC")}, symbol = {references = with_leader("xr"), bindings = with_leader("xb"), definition = with_leader("xd"), set_locations = with_leader("xs")}, macro = {callers = with_leader("xe")}, class = {methods = with_leader("xm")}, prompt = with_leader("xi")}, compile = {expr = with_leader("ce"), toplevel_expr = with_leader("ct"), file = with_leader("cf")}, describe = {operator = with_leader("do"), atom = with_leader("da"), prompt = with_leader("di")}, apropos = {prompt = with_leader("ds")}, arglist = {show = with_leader("dr")}, documentation = {operator = with_leader("ddo"), atom = {"K", with_leader("dda")}, prompt = with_leader("ddi")}, inspect = {atom_expr = with_leader("ii"), atom = with_leader("ia"), expr = with_leader("ie"), toplevel_expr = with_leader("it"), symbol = with_leader("is"), prompt = with_leader("in")}, trace = {show = with_leader("td"), toggle = with_leader("tt"), prompt = with_leader("ti")}, undefine = {["function"] = with_leader("uf"), symbol = with_leader("us"), prompt = with_leader("ui")}}, insert = {space_arglist = "<Space>", cr_arglist = "<CR>"}, visual = {repl = {send_selection = with_leader("s")}, compile = {selection = with_leader("c")}, inspect = {selection = with_leader("i")}}}
local sldb_mappings = {normal = {action = "<CR>", details = "d", frame = {toggle_details = "d", source = {open = "S", open_split = "<C-s>", open_vsplit = "<C-v>", open_tab = "<C-t>"}, restart = "r", eval_expr = "e", send_expr = "E", disassemble = "D", return_result = "R", step = "s"}, local_var = {source = "O", inspect = "i"}, step_over = "x", step_out = "o", abort = "a", continue = "c", inspect_condition = "C"}}
local apropos_mappings = {normal = {inspect = "i"}}
local inspector_mappings = {normal = {action = "<CR>", current_value = {send = "s", source = "o"}, inspected_value = {send = "S", source = "O", previous = "<C-o>", next = "<C-i>"}, next_field = {"<Tab>", "<C-n>"}, prev_field = {"<S-Tab>", "<C-p"}, refresh = "R"}}
local notes_mappings = {normal = {source = {open = "<CR>", open_split = "<C-s>", open_vsplit = "<C-v>", open_tab = "<C-t>"}}}
local server_mappings = {normal = {connect = with_leader("c"), stop = with_leader("s")}}
local threads_mappings = {normal = {interrupt = "<C-c>", kill = "K", invoke_debugger = "D", refresh = "r"}}
local trace_mappings = {normal = {action = "<CR>", refresh = "R", inspect_value = "i", send_value = "s", next_field = {"<Tab>", "<C-n>"}, prev_field = {"<S-Tab>", "<C-p"}}}
local mrepl_mappings = {normal = {clear = with_leader("C"), disconnect = with_leader("D")}, insert = {space_arglist = "<Space>", cr_arglist = "<C-j>", submit = "<CR>", interrupt = "<C-c>"}}
local xref_mappings = {normal = {source = {open = "<CR>", open_split = "<C-s>", open_vsplit = "<C-v>", open_tab = "<C-t>"}}}
local default_mappings = {global = global_mappings, lisp = lisp_mappings, input = input_mappings, repl = repl_mappings, sldb = sldb_mappings, apropos = apropos_mappings, inspector = inspector_mappings, notes = notes_mappings, server = server_mappings, threads = threads_mappings, trace = trace_mappings, xref = xref_mappings, mrepl = mrepl_mappings}
config["mappings"] = vim.tbl_deep_extend("force", default_mappings, vim.g.nvlime_mappings)
return config
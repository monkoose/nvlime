local lsp_types = require("cmp.types.lsp")
local buffer = require("nvlime.buffer")
local opts = require("nvlime.config")
local psl = require("parsley")
require("cmp.types.cmp")
local _2bfuzzy_3f_2b
local function _1_(_241)
  return ("SWANK-FUZZY" == _241)
end
_2bfuzzy_3f_2b = not psl["empty?"](psl.filter(_1_, opts.contribs))
local flag_kind = {b = lsp_types.CompletionItemKind.Variable, f = lsp_types.CompletionItemKind.Function, g = lsp_types.CompletionItemKind.Method, c = lsp_types.CompletionItemKind.Class, t = lsp_types.CompletionItemKind.Class, m = lsp_types.CompletionItemKind.Operator, s = lsp_types.CompletionItemKind.Operator, p = lsp_types.CompletionItemKind.Module}
local kind_precedence = {lsp_types.CompletionItemKind.Module, lsp_types.CompletionItemKind.Class, lsp_types.CompletionItemKind.Operator, lsp_types.CompletionItemKind.Method, lsp_types.CompletionItemKind.Function, lsp_types.CompletionItemKind.Variable}
local function flags__3ekind(flags)
  local kinds = {}
  for i = 1, #flags do
    local kind = flag_kind[flags:sub(i, i)]
    if kind then
      kinds[kind] = true
    else
    end
  end
  for _, kind in ipairs(kind_precedence) do
    if kinds[kind] then
      return kind
    else
    end
  end
  return nil
end
local function set_documentation(item)
  local get_documentation = vim.fn["nvlime#cmp#get_docs"]
  local function _4_(_241)
    item["documentation"] = string.gsub(_241, "^Documentation for the symbol.-\n\n", "", 1)
    return nil
  end
  return get_documentation(item.label, _4_)
end
local get_lsp_kind
if _2bfuzzy_3f_2b then
  local function _5_(item)
    local flags = item[4]
    local kind = (flags__3ekind(flags) or lsp_types.CompletionItemKind.Keyword)
    local label = psl.first(item)
    local base = {label = label, labelDetails = {detail = flags}, kind = kind}
    if ((kind == lsp_types.CompletionItemKind.Function) or (kind == lsp_types.CompletionItemKind.Operator) or (kind == lsp_types.CompletionItemKind.Method)) then
      base["insertText"] = ("(" .. label .. " $0)")
      base["insertTextFormat"] = 2
    else
    end
    return base
  end
  get_lsp_kind = _5_
else
  local function _7_(_241)
    return {label = _241}
  end
  get_lsp_kind = _7_
end
local get_completion
local _9_
if _2bfuzzy_3f_2b then
  _9_ = "nvlime#cmp#get_fuzzy"
else
  _9_ = "nvlime#cmp#get_simple"
end
get_completion = vim.fn[_9_]
local source = {}
source.is_available = function(self)
  return not psl["null?"](buffer["get-conn-var!"](0))
end
source.get_debug_name = function(self)
  return "CMP Nvlime"
end
source.get_keyword_pattern = function(self)
  return "\\k\\+"
end
source.complete = function(self, params, callback)
  local on_done
  local function _11_(candidates)
    local function _12_()
      local tbl_21_ = {}
      local i_22_ = 0
      for _, c in ipairs((candidates or {})) do
        local val_23_ = get_lsp_kind(c)
        if (nil ~= val_23_) then
          i_22_ = (i_22_ + 1)
          tbl_21_[i_22_] = val_23_
        else
        end
      end
      return tbl_21_
    end
    return callback(_12_())
  end
  on_done = _11_
  local input = string.sub(params.context.cursor_before_line, params.offset)
  return get_completion(input, on_done)
end
source.resolve = function(self, item, callback)
  set_documentation(item)
  local function _14_()
    return callback(item)
  end
  return vim.defer_fn(_14_, 5)
end
return source
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
    return {label = psl.first(item), labelDetails = {detail = flags}, kind = (flags__3ekind(flags) or lsp_types.CompletionItemKind.Keyword)}
  end
  get_lsp_kind = _5_
else
  local function _6_(_241)
    return {label = _241}
  end
  get_lsp_kind = _6_
end
local get_completion
local _8_
if _2bfuzzy_3f_2b then
  _8_ = "nvlime#cmp#get_fuzzy"
else
  _8_ = "nvlime#cmp#get_simple"
end
get_completion = vim.fn[_8_]
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
  local function _10_(candidates)
    local function _11_()
      local tbl_17_auto = {}
      local i_18_auto = #tbl_17_auto
      for _, c in ipairs((candidates or {})) do
        local val_19_auto = get_lsp_kind(c)
        if (nil ~= val_19_auto) then
          i_18_auto = (i_18_auto + 1)
          do end (tbl_17_auto)[i_18_auto] = val_19_auto
        else
        end
      end
      return tbl_17_auto
    end
    return callback(_11_())
  end
  on_done = _10_
  local input = string.sub(params.context.cursor_before_line, params.offset)
  return get_completion(input, on_done)
end
source.resolve = function(self, item, callback)
  set_documentation(item)
  local function _13_()
    return callback(item)
  end
  return vim.defer_fn(_13_, 5)
end
return source
# Changelog

All notable changes to Nvlime plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and does not adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2022-12-23 (Birth of the fork)

### Added

- **sldb**: proper toggling of frame. Also removes snippet and file
  location information from it.
- **xref**: shows source file location.
- **apropos**: keymap `i` to show inspector for the symbol.
- **input**: Shows previous history entry with virtual lines, when buffer
  is empty.
- New syntax files for documentation, description, macroexpand, threads,
  xref, compiler notes, apropos, keymaps help and disassembly.
- nvim-cmp source for code autocompletion.
- Global keymaps `q`, `<Esc>`, `<leader>ww`, `<C-n>`, `<C-p>` and `<F1>`.
- Keymap to show documentation `K`.
- New options: `g:nvlime_main_win`, `g:nvlime_enable_cmp`,
  `g:nvlime_scroll_step`, `g:nvlime_scroll_down`, `g:nvlime_scroll_up`,
  `g:nvlime_disable_mappings`, `g:nvlime_disable_global_mappings`,
  `g:nvlime_disable_xref_mappings`, `g:nvlime_disable_apropos_mappings`,
  `g:nvlime_disable_sldb_mappings`, `g:nvlime_disable_repl_mappings`,
  `g:nvlime_disable_inspector_mappings`,
  `g:nvlime_disable_server_mappings`, `g:nvlime_disable_trace_mappings`,
  `g:nvlime_disable_notes_mappings`,

### Changed

- vlime is renamed to nvlime everywhere in the source code.
- Content of vim directory moved to top level.
- All windows except for repl, sbcl and compiler notes spawn as floating
  windows.
- Some parts of the plugin rewritten in fennel.
- `g:nvlime_input_history_limit` from 200 to 100.
- Keymaps are binded in the after/ftplugin files and to generate their
  documentation built-in description of `nvim_set_keymap()` is used.
- Some keymaps are changed: `<leader>t -> <leader>T` for threads, `<leader>i ->
  <leader>I` for interaction mode, inspector keymaps starting with `<leader>i`
  instead of `<leader>I`, trace dialog keymaps starting with `<leader>t`
  instead of `<leader>T`, compiler keymaps starting with `<leader>c` instead of
  `<leader>o`.
- **inspector** additional highlighting uses extmarks instead of matchadd().
- **input**: `<CR>` keymap when input buffer is empty will send previous
  history entry instead of canceling it.

### Removed

- Config variables: `g:vlime_buf_name_sep`, `g:vlime_window_settings`, `g:vlime_cl_use_terminal`,
`g:vlime_force_default_keys`
- Keymaps for closing plugin windows.
- Mapping overlays
- async code related to vim
- asyncomplete sources.

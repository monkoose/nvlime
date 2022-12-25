<p align="center">
    <img src="https://user-images.githubusercontent.com/6261276/209430731-dccaeebd-23e4-4f55-b8c3-4a6bfec7f01b.jpg" alt="Nvlime logo">
</p>

**WARNING:**
[parsley][parsley] neovim plugin should be installed for Nvlime to work.

## Intro

Nvlime is a Common Lisp development environment for Neovim, similar to SLIME
for Emacs. It is a fork of long lived [Vlime][Vlime] plugin but with modernized
UI.

It provides REPL integration, autocompletion with [nvim-cmp][nvim-cmp], cross
reference utilities, a nice inspector, debugger, trace dialog, and many other
great facilities.

To get your feet wet: [Quickstart](#Quickstart)

## Why?

Vlime is a good plugin on top of the great tool. But it tries to sit on both
chairs (Vim and Neovim), when their feature implementations keep diverging. Also
it's UI is clunky and disruptive (at least for my taste). So Nvlime is
supporting only Neovim and focusing on improving Vlime UI with new Neovim
features. Check `CHANGELOG.md` to find out what have changed.

## Current State

Nvlime is currently in beta state. MREPLs currently do not work.
Please beware of bugs, and file an issue if you find anything weird/unexpected.

## Dependencies

Must-have:

- Neovim master branch with the support of a title for `nvim_open_win()`
  [1af4bd0](https://github.com/neovim/neovim/commit/1af4bd04f9ad157edbfea30642250e854c5cb5d2)
- Helper plugin [parsley][parsley]
- ASDF
- Quicklisp
- An Internet connection to install other dependencies from Quicklisp

Good to have:

- [nvim-cmp][nvim-cmp] for autocompletion
- parinfer or paredit plugin - Nvlime can only detect s-expressions inside
  parentheses. To make your life easier, use
  [paredit](https://github.com/kovisoft/paredit) or any of parinfer
  implementations, like:
  [nvim-parinfer](https://github.com/gpanders/nvim-parinfer) or
  [nvim-parinfer-rust](https://github.com/harrygallagher4/nvim-parinfer-rust).
  Even though paredit isn't perfect, but in my experience parinfer
  plugins are the cause of annoying bugs at the time of this writing.

## Supported CL Implementations

The CL implementations listed below are supported. If you tried out Nvlime with
an implementation not listed here, please let me know (see the Contributing
section below for contact info).

| Implementation | Version | Notes                                   |
|----------------|---------|-----------------------------------------|
| ABCL           | 1.4.0   | Supported by the nvlime-patched backend |
| Allegro CL     | 10.0    | Tested with the Express Edition         |
| CLISP          | 2.49+   | No multithreading support               |
| ECL            | 16.1.3  | No SLDB support                         |
| CCL            | 1.11    |                                         |
| SBCL           | 2.1.19  |                                         |
| LispWorks      | 6.1     | Tested with the Personal Edition        |

## Quickstart

### Installation

Use `:h packages` or your plugin manager instructions to add Nvlime to Neovim.
As dependency Nvlime uses [parsley][parsley] - it is my plugin with a bunch
of auxiliary functions. So it should be installed too. After that run `sbcl
--load <neovim plugins dir>/nvlime/lisp/start-nvlime.lisp`.

If it's your first time running the server, Nvlime will try to install it's
dependencies via Quicklisp.

### Usage

When the server is up and running, use Neovim to start editing a CL source
file, and type `<leader>cc` (`\cc` by default) in normal mode to connect to the
server.

You can also let Neovim start the server for you - `<leader>rr`. See `:help
nvlime-start-up` for more info.

All Nvlime keymaps starts with the "leader", so change `g:nvlime_leader` to key
that is convenient for you (by default it is mapped to `\`). Suggested keys are
`,` or `<Space>`.

To find out all plugin mappings for the current window type `<leader>?` or
`<F1>`. There are a set of global mappings, which do not show in the help window.
They are listed below and work for all Nvlime windows:

- `q` - to close the current window (except for lisp filetypes).
- `<leader>ww` - closes all plugin windows except main windows.
- `<Esc>` - closes last opened floating window except current one.
- `<C-n>` and `<C-p>` to scroll last opened floating window. If this keys are
  messing up with your config change them with `g:nvlime_scroll_up` and
  `g:nvlime_scroll_down`. Example `let g:nvlime_scroll_up = '<C-u>'`
  *(vimscript)* or `vim.g.nvlime_scroll_down = '<C-d>'` *(lua)*. You can adjust scroll
  step with `g:nvlime_scroll_step` variable. It is set to `3` lines by default.

If you need to make some floating window persistent, just make it a normal
window. You can do it by splitting it into you current window with `<C-w>h`,
`<C-w>j`, `<C-w>k`, `<C-w>l` or split the whole Neovim screen with `<C-w>H`,
`<C-w>J`, `<C-w>K` or `<C-w>L`.

Main windows (repl, sbcl and compiler notes) aren't floating and by default
placed on the right side of the screen. You can change this behavior with
`g:nvlime_main_win` variable, which can accept one position from `"top"`,
`"bottom"`, `"left"` or `"right"`.

To enable autocompletion with [nvim-cmp][nvim-cmp], first set `let
g:nvlime_enable_cmp = v:true`.
Additionally you need to register the source for nvim-cmp, read its
documentation for more information:

```lua
require('cmp').setup.filetype({'lisp'}, {
    sources = {
        { name = 'nvlime' }
        -- other sources like path or buffer, etc.
        -- .
        -- .
    }
})
```

See `:help nvlime-tutor` for a tutorial on how to use the main features, and
`:help nvlime` for the full documentation.

## Contributing

The source repo for Nvlime is hosted on GitHub:

    https://github.com/monkoose/nvlime

Issues and pull requests are welcome. Read `CONTRIBUTING.md` for more info.

## Credits

- To all the contributors of [slime](https://github.com/slime/slime) Emacs
  extension. SLIME is free software.
- To all the contributors of [Vlime][Vlime] plugin. Without it there wouldn't
  be Nvlime. MIT license.
- To [HiPhish](https://github.com/HiPhish) for
  [nvim-cmp-vlime](https://github.com/HiPhish/nvim-cmp-vlime) Some code from it
  were converted from lua to fennel for autocompletion support. MIT license.

## License

MIT. See `LICENSE.txt`.

[nvim-cmp]: https://github.com/hrsh7th/nvim-cmp
[Vlime]: https://github.com/vlime/vlime
[parsley]: https://github.com/monkoose/parsley

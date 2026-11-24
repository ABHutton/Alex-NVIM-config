# Neovim config

Personal configuration based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), with custom plugins in `lua/custom/`.

**Neovim 0.12+** recommended.

## What's included

| Area | Plugins / config | Notes |
|------|------------------|-------|
| Pickers, explorer, dashboard, LazyGit | [snacks.nvim](lua/custom/plugins/snacks.lua) | `<leader>og` LazyGit |
| LSP | [lsp.lua](lua/custom/plugins/lsp.lua): `lua_ls`, `ruby_lsp`, nvim-java (`jdtls`) | `<leader>rd` adds a RuboCop disable/enable pair for the diagnostic on the current line |
| Completion, formatting | [blink.cmp](lua/custom/plugins/completion.lua), [conform.nvim](lua/custom/plugins/formatting.lua) | |
| Treesitter | [nvim-treesitter + context](lua/custom/plugins/treesitter.lua) | Parsers auto-install on startup |
| Git / GitHub / Jira | [gitsigns](lua/custom/plugins/git.lua), [Atlas](lua/custom/plugins/atlas.lua) | `<leader>g…` Atlas pulls, Jira, PRs |
| Markdown | [render-markdown, live-preview, obsidian.nvim](lua/custom/plugins/markdown.lua) | `<leader>op` browser preview; Obsidian vault at `~/dev/Obsidian` |
| Databases | [vim-dadbod + UI](lua/custom/plugins/dadbod.lua) | `<leader>db` toggle UI |
| Tests | [vim-test](lua/custom/plugins/vim_test.lua) | Runs in a herdr pane, or tmux via vimux |
| Pane navigation | [tuios-nvim-navigator](lua/custom/plugins/tuios_nvim_navigator.lua), [vim-tmux-navigator / herdr](lua/custom/plugins/vim_tmux_navigator.lua) | `<C-h/j/k/l>` across splits and multiplexer panes |
| Quickfix | [quicker.nvim](lua/custom/plugins/quicker.lua) | `<leader>q` quickfix, `<leader>l` loclist, `<leader>xd` diagnostics |
| Editing | [multicursor.nvim](lua/custom/plugins/multicursor.lua), [autopairs](lua/kickstart/plugins/autopairs.lua) | `<leader>m…` / `<C-q>` multi-cursor |
| Theme | [Omarchy theme sync](lua/custom/omarchy-theme.lua) | Follows the current Omarchy theme, falls back to Tokyo Night |
| Fun | [typr](lua/custom/plugins/typr.lua) | `:Typr`, `:TyprStats` typing practice |

Debugging (nvim-dap) is present but disabled — see `init.lua`.

## Documentation

| Doc | Contents |
|-----|----------|
| **[SETUP.md](SETUP.md)** | New machine: system deps, Mason/Treesitter auto-install, optional stacks (Ruby, Java, Atlas, LazyGit, …), verify steps |
| **[.env.example](.env.example)** | Template for local Atlas/Jira secrets (copy to `.env`) |
| [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) | Upstream project this fork started from |

## Quick start

1. Follow [SETUP.md — Quick start](SETUP.md#quick-start).
2. Clone into `~/.config/nvim` and run `nvim`.

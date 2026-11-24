# Setup guide

This document lists everything you need on a **new machine** beyond cloning this repo. Plugins are installed by [lazy.nvim](https://github.com/folke/lazy.nvim) on first launch; the items below are system tools and runtimes.

## Quick start

1. Install the [core dependencies](#core-required).
2. Install any [optional stacks](#optional-by-feature) you use (Ruby, Java, Markdown / Obsidian, databases, tests, pane navigation, Atlas / GitHub CLI + Jira, LazyGit, Omarchy theme).
3. Clone this config into `~/.config/nvim` (or `$XDG_CONFIG_HOME/nvim`).
4. Start Neovim and run `:Lazy` — wait for plugins and Mason tools to finish installing.
5. Run `:checkhealth kickstart`, `:checkhealth nvim-treesitter`, `:checkhealth snacks`, and `:checkhealth atlas` (if using Atlas).

---

## Core (required)

| Dependency | Why |
|------------|-----|
| [Neovim](https://neovim.io/) ≥ 0.12 (recommended) | Treesitter parser manager (`nvim-treesitter` `main` branch). Older versions fall back to the legacy `master` branch |
| `git` | Plugin installs, gitsigns, project roots |
| `make` | LuaSnip optional build (`install_jsregexp`) on non-Windows |
| `unzip` | Kickstart health check |
| C compiler (`gcc`) | Native plugin and Treesitter parser builds |
| `curl` + `tar` | Download Treesitter parser sources |
| [`tree-sitter-cli`](https://github.com/tree-sitter/tree-sitter) (≥ 0.26) | Install/update Treesitter parsers (`:TSInstall`, auto-install on startup) |
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | Snacks picker: grep, live grep, buffer search |
| [fd](https://github.com/sharkdp/fd) or `fdfind` | Snacks picker: files, explorer, projects. On Debian/Ubuntu the package is `fd-find` and the binary is `fdfind` |

### Ubuntu / Debian example

```sh
sudo apt install neovim git make gcc ripgrep fd-find unzip curl tar tree-sitter-cli
```

### Clipboard

`init.lua` sets `clipboard=unnamedplus`. On Linux you typically need one of:

- `wl-clipboard` (Wayland)
- `xclip` or `xsel` (X11)

```sh
sudo apt install wl-clipboard   # Wayland
# or
sudo apt install xclip          # X11
```

### Font (recommended)

A [Nerd Font](https://www.nerdfonts.com/) is assumed (`vim.g.have_nerd_font = true` in `init.lua`).

---

## Installed automatically by Neovim

### Mason (LSP tools)

On first use, [mason-tool-installer](lua/custom/plugins/lsp.lua) installs:

| Tool | Used for |
|------|----------|
| `lua_ls` | Lua LSP |
| `ruby_lsp` | Ruby LSP |
| `stylua` | Lua formatting (conform.nvim) |

nvim-java manages its own `jdtls` install (see [Java](#java)).

### Treesitter parsers

[nvim-treesitter](lua/custom/plugins/treesitter.lua) (Neovim 0.12+: `main` branch) installs these parsers in the **background** on startup if they are missing:

`bash`, `c`, `diff`, `html`, `lua`, `luadoc`, `markdown`, `markdown_inline`, `query`, `sql`, `vim`, `vimdoc`, `ruby`

- Parsers live in `~/.local/share/nvim/site/parser/` (not committed to git).
- `:TSUpdate` (plugin build step) refreshes installed parsers when the plugin updates.
- Sticky function context at the top of the window: [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) (`:TSContext toggle`).

Requires `curl`, `tar`, `tree-sitter-cli`, and `gcc` on the system (see [core dependencies](#core-required)).

No manual `:TSInstall` needed on a normal first boot, but retry failed downloads with e.g. `:TSInstall sql`.

---

## Optional (by feature)

### Ruby

| Dependency | Why |
|------------|-----|
| Ruby | `ruby_lsp` and Treesitter; RuboCop-style diagnostics for `<leader>rd` in `init.lua` |

Mason installs the `ruby_lsp` binary, but you still need a Ruby runtime on the system.

### Java

| Dependency | Why |
|------------|-----|
| JDK | [nvim-java](lua/custom/plugins/lsp.lua) enables `jdtls` |

```sh
sudo apt install openjdk-17-jdk   # or your preferred version
```

### Markdown (render-markdown, live-preview, Obsidian)

| Dependency | Why |
|------------|-----|
| A web browser | `<leader>op` toggles a live preview (`:LivePreview start` / `close`) in the default browser; no build step |
| Obsidian vault at `~/dev/Obsidian` | [obsidian.nvim](lua/custom/plugins/markdown.lua) only loads for `.md` files under that path; change `workspaces` if your vault lives elsewhere |

[render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) renders Markdown in the buffer and needs nothing extra beyond the `markdown` / `markdown_inline` Treesitter parsers.

### Databases (vim-dadbod)

| Dependency | Why |
|------------|-----|
| A database CLI client, e.g. `psql` | vim-dadbod shells out to it to run queries |

`<leader>db` toggles the DB UI, `<leader>da` adds a connection, `<leader>df` finds a query buffer. Predefined connections live in `vim.g.dbs` in [`lua/custom/plugins/dadbod.lua`](lua/custom/plugins/dadbod.lua) (currently local `nspack_gr` / `nspack_test` Postgres databases). Saved queries go to `stdpath('data')/dadbod_ui`.

```sh
sudo apt install postgresql-client
```

### Tests (vim-test)

| Dependency | Why |
|------------|-----|
| [herdr](https://github.com/herdrdev/herdr) **or** tmux | Where tests run. Inside herdr (`$HERDR_ENV` set) a custom strategy ([`lua/custom/herdr_test.lua`](lua/custom/herdr_test.lua)) runs them in a herdr pane; otherwise vimux is used, which needs a tmux session |

`<leader>vn` nearest test, `<leader>vf` test file, `<leader>vb` run `brake`.

### Pane navigation (`<C-h/j/k/l>`)

The same keys move between Neovim splits and the surrounding terminal multiplexer. Which plugin owns them depends on the environment:

| Environment | Handled by |
|-------------|------------|
| tuios (`$TUIOS_ENV=1`) | [tuios-nvim-navigator](lua/custom/plugins/tuios_nvim_navigator.lua). Keys must match `appearance.nvim_navigation` / `terminal_focus_*` in `~/.config/tuios/config.toml` |
| herdr navigation plugin installed | `~/.config/herdr/plugins/github/vim-herdr-navigation-*/editor/nvim.lua` is loaded by [vim_tmux_navigator.lua](lua/custom/plugins/vim_tmux_navigator.lua) |
| Anything else | Plain vim-tmux-navigator mappings (needs tmux to cross pane boundaries) |

### Omarchy theme

| Dependency | Why |
|------------|-----|
| [Omarchy](https://omarchy.org/) (optional) | The colourscheme follows the current Omarchy theme |

[`lua/custom/omarchy-theme.lua`](lua/custom/omarchy-theme.lua) reads `~/.local/state/omarchy/current/theme/neovim.lua` (and `theme.name`) and installs/applies the matching colourscheme plugin. It re-applies on `:Lazy reload`. Without Omarchy, or if that file is missing, it falls back to Tokyo Night. Transparency is applied from [`plugin/after/transparency.lua`](plugin/after/transparency.lua).

### Atlas (atlas.nvim)

| Dependency | Why |
|------------|-----|
| [GitHub CLI](https://cli.github.com/) (`gh`) | Atlas GitHub pulls (`<leader>gp`, `<leader>gc`, …) |
| `curl` | Atlas HTTP for Jira and other providers |
| Jira Cloud API token | Atlas Jira issues (`<leader>gj`, `<leader>gi`) |

```sh
sudo apt install gh curl
# or see https://github.com/cli/cli#installation
```

Authenticate GitHub once per machine:

```sh
gh auth login
```

Store Jira credentials in `~/.config/nvim/.env` (gitignored; copy from `.env.example`):

```sh
cp ~/.config/nvim/.env.example ~/.config/nvim/.env
# then edit .env:
# JIRA_BASE_URL=https://your-site.atlassian.net
# JIRA_EMAIL=you@example.com
# JIRA_API_TOKEN=your_jira_api_token
```

Neovim loads that file on startup via `lua/custom/env.lua`. Shell exports still override `.env` when set.

Create an API token at [Atlassian account API tokens](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/).

Atlas leader keys: `<leader>gp` pulls, `<leader>gj` Jira, `<leader>gc` create PR, `<leader>gi` create issue, `<leader>go` open, `<leader>gn` notes.

PR review/checkout uses `pulls.repo_config.paths` in `lua/custom/plugins/atlas.lua` (currently `AgrigateOne/*` → `~/dev/*`). Without a mapping, Atlas tries an HTTPS cache clone, which often fails for private repos when git is set up for SSH. Add more `org/*` → `~/path/*` entries as needed.

### LazyGit (snacks.nvim)

| Dependency | Why |
|------------|-----|
| [lazygit](https://github.com/jesseduffield/lazygit) | Required for `<leader>og`; Snacks wraps the CLI |

```sh
sudo apt install lazygit
# or: go install github.com/jesseduffield/lazygit@latest
```

---

## Not loaded by default

| Dependency | Status |
|------------|--------|
| nvim-dap + debug adapters | Listed in `lazy-lock.json`, but `require 'kickstart.plugins.debug'` is **commented out** in `init.lua` |

---

## Verify installation

Inside Neovim:

```vim
:checkhealth kickstart
:checkhealth nvim-treesitter
:checkhealth snacks
:checkhealth atlas
:Mason
:lua vim.print(require('nvim-treesitter').get_installed())
```

From a shell:

```sh
git --version
rg --version
fdfind --version   # or fd --version
psql --version        # if using vim-dadbod with Postgres
herdr --version       # if running tests via herdr (or: tmux -V for vimux)
gh --version          # if using Atlas GitHub integration
gh auth status        # if using Atlas GitHub integration
test -f ~/.config/nvim/.env   # if using Atlas Jira
lazygit --version     # if using LazyGit integration
```

---

## Related files

| File | Contents |
|------|----------|
| `README.md` | Overview of this config and quick start |
| `init.lua` | Core options and keymaps |
| `.env.example` | Template for local Atlas/Jira secrets (copy to `.env`) |
| `lua/custom/plugins/` | Custom plugin configuration |
| `lazy-lock.json` | Pinned plugin versions for reproducible installs |

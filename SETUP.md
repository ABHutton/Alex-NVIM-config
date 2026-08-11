# Setup guide

This document lists everything you need on a **new machine** beyond cloning this repo. Plugins are installed by [lazy.nvim](https://github.com/folke/lazy.nvim) on first launch; the items below are system tools and runtimes.

## Quick start

1. Install the [core dependencies](#core-required).
2. Install any [optional stacks](#optional-by-feature) you use (Ruby, Java, markdown preview, Cursor Agent, Atlas / GitHub CLI + Jira, LazyGit).
3. Clone this config into `~/.config/nvim` (or `$XDG_CONFIG_HOME/nvim`).
4. Start Neovim and run `:Lazy` — wait for plugins and Mason tools to finish installing.
5. Run `:checkhealth kickstart`, `:checkhealth snacks`, and `:checkhealth atlas` (if using Atlas).

---

## Core (required)

| Dependency | Why |
|------------|-----|
| [Neovim](https://neovim.io/) ≥ 0.10 | Required by `kickstart/health.lua` |
| `git` | Plugin installs, gitsigns, project roots |
| `make` | LuaSnip optional build (`install_jsregexp`) on non-Windows |
| `unzip` | Kickstart health check |
| C compiler (`gcc`) | Some native plugin builds (see kickstart README) |
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | Snacks picker: grep, live grep, buffer search |
| [fd](https://github.com/sharkdp/fd) or `fdfind` | Snacks picker: files, explorer, projects. On Debian/Ubuntu the package is `fd-find` and the binary is `fdfind` |

### Ubuntu / Debian example

```sh
sudo apt install neovim git make gcc ripgrep fd-find unzip
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

## Installed automatically by Neovim (Mason)

On first use, [mason-tool-installer](lua/custom/plugins/lsp.lua) installs:

| Tool | Used for |
|------|----------|
| `lua_ls` | Lua LSP |
| `ruby_lsp` | Ruby LSP |
| `stylua` | Lua formatting (conform.nvim) |
| `markdownlint` | Markdown linting (nvim-lint) |

[Treesitter](lua/custom/plugins/treesitter.lua) grammars are installed via the plugin build (`:TSUpdate`): bash, c, diff, html, lua, luadoc, markdown, query, vim, vimdoc, ruby.

No manual install needed for these beyond starting Neovim and letting Mason finish.

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

### Markdown preview (peek.nvim)

| Dependency | Why |
|------------|-----|
| [Deno](https://deno.land/) | Plugin build: `deno task --quiet build:fast` |
| webview or a browser | Preview window (`app = 'webview'` in `lua/custom/plugins/markdown.lua`) |

Install Deno:

```sh
curl -fsSL https://deno.land/install.sh | sh
```

Ensure `deno` is on your `PATH`, then run `:Lazy` so peek.nvim can build.

To use a browser instead of webview, change `app` in `lua/custom/plugins/markdown.lua` (e.g. `app = 'browser'`).

### Cursor Agent (cursor-agent.nvim)

| Dependency | Why |
|------------|-----|
| `cursor-agent` CLI | `<leader>aa`, `<leader>as`, `<leader>ab`, `<leader>ap` |

Install per [Cursor](https://cursor.com/) documentation. The executable must be on `PATH` as `cursor-agent` (or set `cmd` in `require('cursor-agent').setup({ ... })`).

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
:checkhealth snacks
:checkhealth atlas
:Mason
```

From a shell:

```sh
git --version
rg --version
fdfind --version   # or fd --version
deno --version     # if using peek
cursor-agent --help   # if using Cursor Agent integration
gh --version          # if using Atlas GitHub integration
gh auth status        # if using Atlas GitHub integration
test -f ~/.config/nvim/.env   # if using Atlas Jira
lazygit --version     # if using LazyGit integration
```

---

## Related files

| File | Contents |
|------|----------|
| `README.md` | Upstream kickstart.nvim documentation and install recipes |
| `init.lua` | Core options and keymaps |
| `.env.example` | Template for local Atlas/Jira secrets (copy to `.env`) |
| `lua/custom/plugins/` | Custom plugin configuration |
| `lazy-lock.json` | Pinned plugin versions for reproducible installs |

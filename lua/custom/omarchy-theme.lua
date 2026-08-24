--- Omarchy theme integration for kickstart.nvim.
--- Reads ~/.local/state/omarchy/current/theme/neovim.lua (LazyVim-style descriptors)
--- and falls back to Tokyo Night when missing or invalid.
local M = {}

M.theme_file = vim.fn.expand '~/.local/state/omarchy/current/theme/neovim.lua'

---@class OmarchyThemeInfo
---@field plugin string
---@field name? string
---@field colorscheme string
---@field opts? table
---@field dependencies? string[]
---@field branch? string
---@field priority? number
---@field fallback? boolean

M.fallback = {
  plugin = 'folke/tokyonight.nvim',
  colorscheme = 'tokyonight-night',
  opts = {
    transparent = true,
    terminal_colors = true,
    styles = {
      comments = { italic = false },
      sidebars = 'transparent',
      floats = 'transparent',
    },
  },
  priority = 1000,
  fallback = true,
}

--- Known Omarchy/LazyVim descriptor quirks.
local colorscheme_aliases = {
  ['catppuccin-nvim'] = 'catppuccin-mocha',
}

---@param colorscheme string
---@return string
local function resolve_colorscheme(colorscheme)
  return colorscheme_aliases[colorscheme] or colorscheme
end

---@param plugin string
---@param name? string
---@return string
local function plugin_key(plugin, name)
  if name and name ~= '' then
    return name
  end
  return plugin:match '[^/]+$' or plugin
end

---@param spec table
---@return OmarchyThemeInfo?
function M.parse_spec(spec)
  if type(spec) ~= 'table' then
    return nil
  end

  local plugin_entry
  local colorscheme
  local lazyvim_opts

  for _, entry in ipairs(spec) do
    if type(entry) ~= 'table' then
      goto continue
    end

    local plugin = entry[1] or entry.plugin
    if type(plugin) ~= 'string' then
      goto continue
    end

    if plugin:match 'LazyVim' then
      if type(entry.opts) == 'table' then
        lazyvim_opts = entry.opts
        if type(entry.opts.colorscheme) == 'string' then
          colorscheme = entry.opts.colorscheme
        end
      end
    else
      plugin_entry = entry
    end

    ::continue::
  end

  if not plugin_entry then
    return nil
  end

  local plugin = plugin_entry[1] or plugin_entry.plugin
  if type(plugin) ~= 'string' or plugin == '' then
    return nil
  end

  if not colorscheme and type(plugin_entry.opts) == 'table' and type(plugin_entry.opts.colorscheme) == 'string' then
    colorscheme = plugin_entry.opts.colorscheme
  end

  if not colorscheme then
    return nil
  end

  local opts = vim.deepcopy(plugin_entry.opts or {})
  opts.colorscheme = nil

  if lazyvim_opts then
    for key, value in pairs(lazyvim_opts) do
      if key ~= 'colorscheme' then
        opts[key] = value
      end
    end
  end

  local info = {
    plugin = plugin,
    name = plugin_entry.name,
    colorscheme = colorscheme,
    opts = next(opts) and opts or nil,
    branch = plugin_entry.branch,
    priority = plugin_entry.priority or 1000,
  }

  if type(plugin_entry.dependencies) == 'table' then
    info.dependencies = {}
    for _, dep in ipairs(plugin_entry.dependencies) do
      if type(dep) == 'string' then
        info.dependencies[#info.dependencies + 1] = dep
      elseif type(dep) == 'table' then
        local dep_name = dep[1] or dep.plugin
        if type(dep_name) == 'string' then
          info.dependencies[#info.dependencies + 1] = dep_name
        end
      end
    end
  end

  return info
end

---@return OmarchyThemeInfo?
function M.omarchy_spec()
  if vim.fn.filereadable(M.theme_file) == 0 then
    return nil
  end

  local ok, spec = pcall(dofile, M.theme_file)
  if not ok then
    return nil
  end

  return M.parse_spec(spec)
end

---@return OmarchyThemeInfo
function M.resolve()
  local spec = M.omarchy_spec()
  if not spec then
    return vim.deepcopy(M.fallback)
  end

  if spec.plugin == M.fallback.plugin then
    spec.opts = vim.tbl_deep_extend('force', spec.opts or {}, M.fallback.opts)
  end

  return spec
end

---@return string
function M.colorscheme_name()
  return resolve_colorscheme(M.resolve().colorscheme)
end

---@param info OmarchyThemeInfo
---@return string
function M.plugin_name(info)
  return plugin_key(info.plugin, info.name)
end

---@param info OmarchyThemeInfo
---@return table?
local function lazy_plugin(info)
  return require('lazy.core.config').plugins[M.plugin_name(info)]
end

---@param plugin table
local function unload_plugin_modules(plugin)
  if not plugin or not plugin.dir then
    return
  end

  local lua_dir = plugin.dir .. '/lua'
  if vim.uv and vim.uv.fs_stat(lua_dir) then
    require('lazy.core.util').walkmods(lua_dir, function(modname)
      package.loaded[modname] = nil
      package.preload[modname] = nil
    end)
  end
end

---@param dep string|table
---@return table
local function normalize_dependency(dep)
  if type(dep) == 'string' then
    if dep == 'bjarneo/aether.nvim' then
      return {
        'bjarneo/aether.nvim',
        name = 'aether',
        branch = 'v3',
        lazy = true,
        priority = 1000,
      }
    end

    return { dep, lazy = true, priority = 1000 }
  end

  if type(dep) == 'table' then
    local plugin = dep[1] or dep.plugin
    if plugin == 'bjarneo/aether.nvim' and not dep.name then
      dep.name = 'aether'
      dep.branch = dep.branch or 'v3'
    end
    dep.lazy = dep.lazy ~= false
    dep.priority = dep.priority or 1000
    return dep
  end

  return dep
end

---@param info OmarchyThemeInfo
---@return string
local function resolve_module(info)
  local mod = (info.name and info.name:gsub('-', '') or info.plugin:match '[^/]+$'):gsub('%.%w+$', '')
  if info.plugin:match 'tokyonight' then
    mod = 'tokyonight'
  elseif info.plugin:match 'aether' then
    mod = 'aether'
  elseif info.plugin:match 'catppuccin' then
    mod = 'catppuccin'
  elseif info.plugin:match 'everforest' then
    mod = 'everforest'
  elseif info.plugin:match 'gruvbox' then
    mod = 'gruvbox'
  elseif info.plugin:match 'kanagawa' then
    mod = 'kanagawa'
  elseif info.plugin:match 'nightfox' then
    mod = 'nightfox'
  elseif info.plugin:match 'rose%-pine' or info.name == 'rose-pine' then
    mod = 'rose-pine'
  elseif info.plugin:match 'bamboo' then
    mod = 'bamboo'
  elseif info.plugin:match 'ashen' then
    mod = 'ashen'
  elseif info.plugin:match 'lumon' then
    mod = 'lumon'
  elseif info.plugin:match 'matteblack' then
    mod = 'matteblack'
  elseif info.plugin:match 'retro%-82' then
    mod = 'retro82'
  elseif info.plugin:match 'flexoki' then
    mod = 'flexoki'
  elseif info.plugin:match 'ethereal' then
    mod = 'ethereal'
  elseif info.plugin:match 'vantablack' then
    mod = 'vantablack'
  elseif info.plugin:match 'white%.nvim' then
    mod = 'white'
  elseif info.plugin:match 'miasma' then
    mod = 'miasma'
  else
    mod = mod:gsub('%.nvim$', ''):gsub('%-nvim$', '')
  end

  return mod
end

---@param info OmarchyThemeInfo
---@param opts? table
---@return boolean setup_called
local function setup_plugin(info, opts)
  local ok, plugin = pcall(require, resolve_module(info))
  if not ok or type(plugin) ~= 'table' or type(plugin.setup) ~= 'function' then
    return false
  end

  plugin.setup(opts or info.opts or {})
  return true
end

---@param info OmarchyThemeInfo
local function load_colorscheme(info)
  local theme_plugin = lazy_plugin(info)

  if theme_plugin then
    if not theme_plugin._.loaded then
      require('lazy.core.loader').load(theme_plugin, { force = true })
    end
    unload_plugin_modules(theme_plugin)
  end

  if setup_plugin(info) then
    return
  end

  require('lazy.core.loader').colorscheme(info.colorscheme)
end

---@param info? OmarchyThemeInfo
function M.apply(info)
  info = info or M.resolve()
  info.colorscheme = resolve_colorscheme(info.colorscheme)

  vim.cmd 'highlight clear'
  if vim.fn.exists 'syntax_on' then
    vim.cmd 'syntax reset'
  end
  vim.o.background = 'dark'

  local function load_lazy_plugin(name)
    local plugin = require('lazy.core.config').plugins[name]
    if plugin and not plugin._.loaded then
      require('lazy.core.loader').load(plugin, { force = true })
    end
    return plugin
  end

  if info.dependencies then
    for _, dep in ipairs(info.dependencies) do
      local dep_name = dep == 'bjarneo/aether.nvim' and 'aether' or (dep:match '[^/]+$' or dep)
      load_lazy_plugin(dep_name)
    end
  end

  local ok, err = pcall(function()
    load_colorscheme(info)
  end)

  if not ok then
    if not info.fallback then
      vim.notify(
        'Omarchy theme failed (' .. tostring(err) .. '); falling back to Tokyo Night',
        vim.log.levels.WARN
      )
      return M.apply(vim.deepcopy(M.fallback))
    end

    vim.notify('Omarchy theme failed: ' .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  vim.defer_fn(function()
    pcall(vim.cmd.colorscheme, info.colorscheme)

    pcall(function()
      require('lualine').setup {
        options = {
          theme = info.colorscheme,
        },
      }
    end)

    vim.cmd 'redraw!'
  end, 5)

  return true
end

--- Lazy plugin specs for the active Omarchy theme (plus dependencies).
function M.lazy_plugins()
  local info = M.resolve()
  info.colorscheme = resolve_colorscheme(info.colorscheme)
  local plugins = {}

  if info.dependencies then
    for _, dep in ipairs(info.dependencies) do
      plugins[#plugins + 1] = normalize_dependency(dep)
    end
  end

  plugins[#plugins + 1] = {
    info.plugin,
    name = info.name,
    branch = info.branch,
    priority = info.priority or 1000,
    lazy = false,
    opts = info.opts,
    config = function(_, opts)
      if opts then
        info.opts = vim.tbl_deep_extend('force', info.opts or {}, opts)
      end
      M.apply(info)
    end,
  }

  return plugins
end

return M

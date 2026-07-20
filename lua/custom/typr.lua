--- Snacks-aware Typr open/close helpers.
--- Typr uses volt floats; closing it over the Snacks dashboard leaves ghost borders
--- (see https://github.com/nvzone/volt/issues/10).
local M = {}

local api = vim.api
M.typr_filetypes = { 'typr', 'typrstats', 'VoltWindow' }
local typr_fts = M.typr_filetypes

function M.is_typr_filetype(filetype)
  return vim.tbl_contains(typr_fts, filetype)
end

function M.is_typr_buffer(buf)
  buf = buf or 0
  return M.is_typr_filetype(vim.bo[buf].filetype)
end

local autopair_keys = { '<bs>', '<c-h>', '<c-w>', '"', "'", '(', ')', '[', ']', '`', '{', '}' }

local function disable_autopairs(buf)
  pcall(function()
    require('nvim-autopairs').set_buf_rule({}, buf)
    vim.b[buf]['nvim-autopairs'] = 0

    local ok, keys = pcall(vim.api.nvim_buf_get_var, buf, 'autopairs_keymaps')
    if ok and type(keys) == 'table' then
      for _, key in pairs(keys) do
        pcall(vim.api.nvim_buf_del_keymap, buf, 'i', key)
      end
    end

    for _, key in ipairs(autopair_keys) do
      pcall(vim.api.nvim_buf_del_keymap, buf, 'i', key)
    end
  end)
end

--- Disable insert-mode helpers that interfere with typing practice.
function M.disable_editor_plugins(buf)
  vim.b[buf].minisurround_disable = true
  vim.b[buf].miniai_disable = true
  disable_autopairs(buf)
end

local restore_dashboard = false
local closing = false
local cleaned = false

local function snacks()
  return require 'snacks'
end

local function dashboard_open()
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'snacks_dashboard' then
      return vim.fn.bufwinid(buf) ~= -1
    end
  end
  return false
end

--- Close all Snacks dashboard windows and buffers.
local function close_dashboard()
  local closed = false

  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_win_is_valid(win) then
      local buf = api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == 'snacks_dashboard' then
        pcall(api.nvim_win_close, win, true)
        closed = true
      end
    end
  end

  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'snacks_dashboard' then
      pcall(api.nvim_buf_delete, buf, { force = true })
      closed = true
    end
  end

  return closed
end

--- Close Snacks.win backdrop floats (filetype snacks_win_backdrop).
local function close_snacks_backdrops()
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_win_is_valid(win) then
      local buf = api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == 'snacks_win_backdrop' then
        pcall(api.nvim_win_close, win, true)
        if api.nvim_buf_is_valid(buf) then
          pcall(api.nvim_buf_delete, buf, { force = true })
        end
      end
    end
  end
end

local function is_typr_float(win)
  if not api.nvim_win_is_valid(win) then
    return false
  end
  local cfg = api.nvim_win_get_config(win)
  if cfg.relative == '' then
    return false
  end
  local buf = api.nvim_win_get_buf(win)
  if api.nvim_buf_is_valid(buf) and vim.tbl_contains(typr_fts, vim.bo[buf].filetype) then
    return true
  end
  return cfg.relative == 'editor' and cfg.focusable == false and vim.wo[win].winblend > 0
end

local function close_typr_floats()
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if is_typr_float(win) then
      pcall(api.nvim_win_close, win, true)
    end
  end
end

local function reset_typr_state()
  pcall(function()
    local state = require 'typr.state'
    state.buf = nil
    state.statsbuf = nil
    state.reset_vars()
  end)
end

local function ensure_normal_window()
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_win_is_valid(win) and api.nvim_win_get_config(win).relative == '' then
      api.nvim_set_current_win(win)
      return
    end
  end
  vim.cmd 'silent! enew'
end

function M.prepare_open()
  cleaned = false
  restore_dashboard = dashboard_open()
  if restore_dashboard then
    close_dashboard()
  end
  close_snacks_backdrops()
  ensure_normal_window()
end

function M.after_close()
  if cleaned then
    return
  end
  cleaned = true
  closing = true

  close_typr_floats()
  close_snacks_backdrops()
  reset_typr_state()

  vim.schedule(function()
    if restore_dashboard then
      close_dashboard()
      close_snacks_backdrops()
      pcall(function()
        snacks().dashboard.open()
      end)
      restore_dashboard = false
    else
      ensure_normal_window()
    end
    vim.cmd.redraw()
    closing = false
  end)
end

function M.close()
  if closing then
    return
  end
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if is_typr_float(win) then
      local buf = api.nvim_win_get_buf(win)
      if api.nvim_buf_is_valid(buf) then
        pcall(api.nvim_buf_delete, buf, { force = true })
      end
    end
  end
  M.after_close()
end

function M.attach_close_maps(buf)
  vim.keymap.set('n', 'q', M.close, { buffer = buf, desc = 'Close Typr' })
  -- Override volt's single-Esc close; exit only via q or double Esc
  vim.keymap.set('n', '<Esc>', '<Nop>', { buffer = buf, desc = 'Use q or double Esc to close' })
  vim.keymap.set('n', '<Esc><Esc>', M.close, { buffer = buf, desc = 'Close Typr' })
end

local function patch_typr_ui_hints()
  local ui = require 'typr.ui'

  ui.mappings = function()
    return {
      {
        { ' ESC ESC ', 'visual' },
        { ' or ', 'commentfg' },
        { ' q ', 'visual' },
        { ' - Quit ', 'commentfg' },

        { '  ' },

        { ' i ', 'visual' },
        { ' - Start ', 'commentfg' },

        { '                   ' },

        { ' CTRL ', 'visual' },
        { ' ' },
        { ' R ', 'visual' },
        { ' - Restart ', 'commentfg' },
      },
    }
  end

  -- layout captures ui.mappings at load time; update that reference too
  local layout = require 'typr.ui.layout'
  for _, section in ipairs(layout) do
    if section.name == 'mappings' then
      section.lines = ui.mappings
    end
  end
end

--- Read typr stats from disk (plain JSON or legacy dumped-lua format).
local function read_stats_file(path)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end

  local raw = table.concat(vim.fn.readfile(path), '\n')
  if raw ~= '' then
    local ok, data = pcall(vim.json.decode, raw)
    if ok and type(data) == 'table' then
      return data
    end
  end

  local ok, stats = pcall(dofile, path)
  if ok and type(stats) == 'string' then
    local decode_ok, data = pcall(vim.json.decode, stats)
    if decode_ok then
      return data
    end
  end

  return nil
end

--- Typr's default save wraps JSON in single-quoted Lua, which breaks for keys like
--- `"`, `'`, and `\` and throws when a test finishes.
function M.patch_stats()
  local su = require('typr.stats.utils')
  if su._custom_stats_patched then
    return
  end
  su._custom_stats_patched = true

  local state = require('typr.state')

  su.save_str_tofile = function(tb)
    local path = state.config.stats_filepath
    local file = io.open(path, 'wb')
    if not file then
      return
    end
    file:write(vim.json.encode(tb))
    file:close()
  end

  su.restore_stats = function()
    local path = state.config.stats_filepath
    local data = read_stats_file(path)
    if data then
      state.data = data
      return
    end

    state.data = su.gen_default_stats()
    su.save_str_tofile(state.data)
  end
end

--- Typr stores per-character accuracy keys; legacy saves could corrupt the stats file.
local function ensure_valid_stats()
  local path = vim.fn.stdpath 'data' .. '/typrstats'
  if vim.fn.filereadable(path) ~= 1 then
    return
  end

  if not read_stats_file(path) then
    os.remove(path)
    vim.notify('Typr stats were corrupt and have been reset.', vim.log.levels.WARN)
  end
end

local function load_typr()
  ensure_valid_stats()
  require('lazy').load { plugins = { 'typr' }, wait = true }
  M.patch_stats()
  require('typr.stats.utils').restore_stats()
  patch_typr_ui_hints()
end

function M.open()
  M.prepare_open()
  load_typr()
  require('typr').open()
end

function M.open_stats()
  M.prepare_open()
  load_typr()
  require('typr.stats').open()
end

return M

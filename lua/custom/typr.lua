--- Snacks-aware Typr open/close helpers.
--- Typr uses volt floats; closing it over the Snacks dashboard leaves ghost borders
--- (see https://github.com/nvzone/volt/issues/10).
local M = {}

local api = vim.api
local typr_fts = { 'typr', 'typrstats', 'VoltWindow' }

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

local function load_typr()
  require('lazy').load { plugins = { 'typr' }, wait = true }
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

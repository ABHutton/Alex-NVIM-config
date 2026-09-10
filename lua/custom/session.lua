--- Session helpers for tpope/vim-obsession.
--- Snacks' built-in `session` dashboard section only recognises a fixed list of
--- session plugins (persistence, persisted, auto-session, ...), so obsession
--- needs its own restore action.
local M = {}

local api = vim.api

--- Path obsession tracks for a directory.
function M.file(dir)
  return (dir or vim.fn.getcwd()) .. '/Session.vim'
end

function M.exists(dir)
  return vim.fn.filereadable(M.file(dir)) == 1
end

local function dashboard_buffers()
  return vim.tbl_filter(function(buf)
    return api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'snacks_dashboard'
  end, api.nvim_list_bufs())
end

--- Windows currently showing the Snacks startup dashboard.
function M.dashboard_wins()
  local wins = {}
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    local buf = api.nvim_win_get_buf(win)
    if api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'snacks_dashboard' then
      wins[#wins + 1] = win
    end
  end
  return wins
end

--- Replace the dashboard with an empty editable buffer so other UIs (e.g. DBUI)
--- can reuse that window instead of opening another split.
function M.dismiss_dashboard()
  for _, win in ipairs(M.dashboard_wins()) do
    api.nvim_set_current_win(win)
    vim.cmd 'enew'
  end
end

--- Source the session file. Obsession's own session file sets `g:this_obsession`,
--- so tracking resumes on its own once the file has been sourced.
function M.restore(dir)
  local file = M.file(dir)
  if vim.fn.filereadable(file) == 0 then
    vim.notify('No session at ' .. vim.fn.fnamemodify(file, ':~:.'), vim.log.levels.WARN)
    return false
  end

  local stale = dashboard_buffers()

  local ok, err = pcall(vim.cmd, 'silent source ' .. vim.fn.fnameescape(file))
  if not ok then
    vim.notify('Failed to restore session: ' .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  -- The dashboard is replaced by the restored windows, but its buffer lingers.
  for _, buf in ipairs(stale) do
    if api.nvim_buf_is_valid(buf) and vim.fn.bufwinid(buf) == -1 then
      pcall(api.nvim_buf_delete, buf, { force = true })
    end
  end

  return true
end

return M

--- vim-test strategy that runs commands in a tuios pane, the tuios
--- equivalent of herdr_test.lua. tuios sets no $TMUX, so vimux aborts with
--- "not inside tmux session" there too.
---
--- The runner pane is split below Neovim's own pane ($TUIOS_PANE_ID). tuios's
--- split takes focus and has no size option, so focus is handed straight back
--- and the split is whatever tuios gives (50/50 by default). If the split
--- fails (no attached client, or tiling off), a plain unfocused window is
--- opened instead.
local M = {}

local runner_pane = nil
-- Directory the runner pane's shell was last moved to; nil = unknown.
local runner_cwd = nil

local function tuios(args)
  local cmd = { 'tuios' }
  vim.list_extend(cmd, args)
  local output = vim.fn.system(cmd)
  return vim.v.shell_error == 0, output
end

local function pane_exists(id)
  local ok = tuios { 'get-window', id }
  return ok
end

local function open_runner_pane()
  local self = vim.env.TUIOS_PANE_ID
  local ok, output = tuios { 'split-window', 'down', '-w', self, '--name', 'vim-test', '--json' }
  if ok then
    local decoded_ok, decoded = pcall(vim.json.decode, output)
    if decoded_ok and decoded.window_id then
      tuios { 'focus-window', self }
      return decoded.window_id
    end
  end

  ok, output = tuios { 'new-window', 'vim-test', '--no-focus', '--print-id', '--cwd', vim.fn.getcwd() }
  if not ok then
    vim.notify('tuios: failed to open test pane\n' .. output, vim.log.levels.ERROR)
    return nil
  end
  return vim.trim(output)
end

local function ensure_runner_pane()
  if runner_pane and pane_exists(runner_pane) then
    return runner_pane
  end
  runner_pane = open_runner_pane()
  runner_cwd = nil
  return runner_pane
end

local function send(pane, cmd)
  -- The pane starts in the source pane's directory, which need not match
  -- Neovim's :cd, and test commands are relative to Neovim's cwd.
  local cwd = vim.fn.getcwd()
  if cwd ~= runner_cwd then
    cmd = 'cd ' .. vim.fn.shellescape(cwd) .. ' && ' .. cmd
  end
  local ok = tuios { 'send-text', '-w', pane, cmd .. '\n' }
  if ok then
    runner_cwd = cwd
  end
  return ok
end

--- Registered as `vim.g['test#custom_strategies'].tuios`.
function M.strategy(cmd)
  local pane = ensure_runner_pane()
  if not pane then
    return
  end

  if not send(pane, cmd) then
    -- The runner pane died between the existence check and the send (e.g.
    -- the user closed it by hand); open a fresh one and retry once.
    runner_pane = nil
    pane = ensure_runner_pane()
    if pane then
      send(pane, cmd)
    end
  end
end

return M

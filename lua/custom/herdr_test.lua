--- vim-test strategy that runs commands in a herdr pane, the herdr
--- equivalent of what preservim/vimux does for tmux. vimux hard-requires
--- $TMUX and shells out to the `tmux` binary, so once tmux stops being the
--- multiplexer in use it just throws "Aborting, because not inside tmux
--- session." on every :TestNearest/:TestFile.
local M = {}

local runner_pane = nil

local function herdr(args)
  local cmd = { 'herdr' }
  vim.list_extend(cmd, args)
  local output = vim.fn.system(cmd)
  return vim.v.shell_error == 0, output
end

local function pane_exists(id)
  local ok = herdr { 'pane', 'get', id }
  return ok
end

local function open_runner_pane()
  -- --ratio sizes the *current* (existing) pane, not the new one, so 0.8
  -- keeps 80% for the editor and leaves ~20% for the new test pane.
  local ok, output = herdr {
    'pane', 'split', '--current',
    '--direction', 'down',
    '--ratio', '0.8',
    '--no-focus',
  }
  if not ok then
    vim.notify('herdr: failed to open test pane', vim.log.levels.ERROR)
    return nil
  end
  return vim.json.decode(output).result.pane.pane_id
end

local function ensure_runner_pane()
  if runner_pane and pane_exists(runner_pane) then
    return runner_pane
  end
  runner_pane = open_runner_pane()
  return runner_pane
end

--- Registered as `vim.g['test#custom_strategies'].herdr`.
function M.strategy(cmd)
  local pane = ensure_runner_pane()
  if not pane then
    return
  end

  local ok = herdr { 'pane', 'run', pane, cmd }
  if not ok then
    -- The runner pane died between the existence check and the run (e.g.
    -- the user closed it by hand); open a fresh one and retry once.
    runner_pane = nil
    pane = ensure_runner_pane()
    if pane then
      herdr { 'pane', 'run', pane, cmd }
    end
  end
end

return M

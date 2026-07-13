--[[
--
-- This file is not required for your own configuration,
-- but helps people determine if their system is setup correctly.
--
--]]

local check_version = function()
  local verstr = tostring(vim.version())
  if not vim.version.ge then
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
    return
  end

  if vim.version.ge(vim.version(), '0.10-dev') then
    vim.health.ok(string.format("Neovim version is: '%s'", verstr))
  else
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
  end
end

local check_external_reqs = function()
  -- Basic utils: `git`, `make`, `unzip`
  for _, exe in ipairs { 'git', 'make', 'unzip', 'rg' } do
    local is_executable = vim.fn.executable(exe) == 1
    if is_executable then
      vim.health.ok(string.format("Found executable: '%s'", exe))
    else
      vim.health.warn(string.format("Could not find executable: '%s'", exe))
    end
  end

  return true
end

local clipboard_install_hint = function()
  if vim.env.WAYLAND_DISPLAY and vim.env.WAYLAND_DISPLAY ~= '' then
    return 'Install wl-clipboard: sudo apt install wl-clipboard'
  end
  if vim.env.DISPLAY and vim.env.DISPLAY ~= '' then
    return 'Install xclip: sudo apt install xclip'
  end
  return 'Install a clipboard tool (xclip for X11, wl-clipboard for Wayland)'
end

local check_clipboard = function()
  vim.health.start 'clipboard'

  local clipboard_opt = vim.o.clipboard
  if clipboard_opt ~= '' then
    vim.health.ok(string.format("clipboard option is set: '%s'", clipboard_opt))
  else
    vim.health.info("clipboard option is not set (yanks won't sync to the system clipboard)")
  end

  local provider = vim.fn['provider#clipboard#Executable']()
  local err = vim.fn['provider#clipboard#Error']()

  if provider == '' then
    vim.health.error(err ~= '' and err or 'No clipboard provider found')
    vim.health.info(clipboard_install_hint())
    return
  end

  if provider == 'tmux' then
    vim.health.warn("Using tmux as the clipboard provider (copies stay in tmux's paste buffer)")
    vim.health.info(clipboard_install_hint())
    return
  end

  vim.health.ok(string.format("Clipboard provider: '%s'", provider))
end

return {
  check = function()
    vim.health.start 'kickstart.nvim'

    vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

    local uv = vim.uv or vim.loop
    vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

    check_version()
    check_external_reqs()
    check_clipboard()
  end,
}

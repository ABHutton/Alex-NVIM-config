--- Load KEY=VALUE pairs from the Neovim config `.env` into `vim.env`.
--- Existing environment variables are left unchanged (shell exports win).

local M = {}

---@param value string
---@return string
local function unquote(value)
  if value:match '^".*"$' or value:match "^'.*'$" then
    return value:sub(2, -2)
  end
  return value
end

---@param path string|nil
function M.load(path)
  path = path or (vim.fn.stdpath 'config' .. '/.env')
  local file = io.open(path, 'r')
  if not file then
    return
  end

  for line in file:lines() do
    local trimmed = line:match '^%s*(.-)%s*$' or ''
    if trimmed ~= '' and not trimmed:match '^#' then
      local key, value = trimmed:match '^([%w_]+)%s*=%s*(.*)$'
      if key and value and (vim.env[key] == nil or vim.env[key] == '') then
        vim.env[key] = unquote(value)
      end
    end
  end

  file:close()
end

return M

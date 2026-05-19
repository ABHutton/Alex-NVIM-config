-- Core settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- Core Keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Custom Keymaps
vim.keymap.set('n', '<leader>p', function()
  vim.fn.setreg('+', vim.fn.expand '%')
  vim.notify('Copied relative path to clipboard', vim.log.levels.INFO)
end, { desc = 'Copy relative file path' })
vim.keymap.set({ 'n', 'v' }, '<leader>rd', function()
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local all_diagnostics = vim.diagnostic.get(0)
  local line_diagnostics = {}
  for _, d in ipairs(all_diagnostics) do
    if d.lnum == line_nr - 1 then
      table.insert(line_diagnostics, d)
    end
  end
  local rule = nil
  if #line_diagnostics > 0 then
    for _, d in ipairs(line_diagnostics) do
      local matched_rule = d.message:match '^([%w_/%d]+):'
      if matched_rule then
        rule = matched_rule
        break
      end
    end
  end
  if not rule then
    vim.notify('No RuboCop diagnostic found on current line.', vim.log.levels.WARN)
    return
  end
  local disable_comment = ('# rubocop:disable %s'):format(rule)
  local enable_comment = ('# rubocop:enable %s'):format(rule)
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' or mode == 'V' then
    local start_line, _ = unpack(vim.api.nvim_buf_get_mark(0, '<'))
    local end_line, _ = unpack(vim.api.nvim_buf_get_mark(0, '>'))
    local indent = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, true)[1]:match '^%s*'

    vim.api.nvim_buf_set_lines(0, end_line, end_line, false, { indent .. enable_comment })
    vim.api.nvim_buf_set_lines(0, start_line - 1, start_line - 1, false, { indent .. disable_comment })
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  else
    local current_line = vim.api.nvim_get_current_line()
    vim.api.nvim_set_current_line(current_line .. ' ' .. disable_comment)
  end
end, { desc = '[R]uboCop [D]isable warning' })

-- Core APIs
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  -- {
  --   'm4xshen/hardtime.nvim',
  --   lazy = false,
  --   dependencies = { 'MunifTanjim/nui.nvim' },
  --   opts = {},
  -- },
  --  require 'kickstart.plugins.debug',
  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns',

  { import = 'custom.plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
-- vim: ts=2 sts=2 sw=2 et

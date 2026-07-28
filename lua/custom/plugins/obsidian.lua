local vault_path = vim.fn.expand '~/dev/Obsidian/Work'

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- use latest release, remove to use latest commit

  dependencies = {
    'nvim-lua/plenary.nvim',
  },

  -- Runs at startup so conceallevel is set before obsidian's BufEnter warning check.
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'markdown', 'quarto' },
      callback = function(ev)
        local file = vim.api.nvim_buf_get_name(ev.buf)
        if vim.startswith(file, vault_path) and ev.buf == vim.api.nvim_get_current_buf() then
          vim.opt_local.conceallevel = 1
        end
      end,
    })
  end,

  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in 4.0.0
    workspaces = {
      {
        name = 'work',
        path = vault_path,
      },
    },
    picker = {
      name = 'snacks.picker',
    },
    callbacks = {
      enter_note = function()
        vim.opt_local.conceallevel = 2
      end,
    },
  },

  keys = {
    {
      '<leader>so',
      function()
        -- Directly open Snacks picker in your vault directory from anywhere
        require('snacks.picker').files { cwd = vault_path }
      end,
      desc = '[S]earch [O]bsidian vault',
    },
  },
}

return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    'toppair/peek.nvim',
    ft = 'markdown',
    build = 'deno task --quiet build:fast',
    keys = {
      {
        '<leader>op',
        function()
          local peek = require 'peek'
          if peek.is_open() then
            peek.close()
          else
            peek.open()
          end
        end,
        desc = 'Markdown [P]review',
      },
    },
    opts = {
      auto_load = false,
      close_on_bdelete = true,
      syntax = true,
      theme = 'dark',
      update_on_change = true,
      app = 'browser',
      filetype = { 'markdown' },
    },
    config = function(_, opts)
      require('peek').setup(opts)
    end,
  },
}

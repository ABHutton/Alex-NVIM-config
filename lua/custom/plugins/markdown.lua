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
    'obsidian-nvim/obsidian.nvim',
    event = { 'BufReadPre ' .. vim.fn.expand '~' .. '/dev/Obsidian/*.md', 'BufNewFile ' .. vim.fn.expand '~' .. '/dev/Obsidian/*.md' },
    keys = {
      { '<leader>op', '<cmd>Obsidian open<cr>', desc = 'Open note in Obsidian ([P]review)' },
    },
    opts = {
      legacy_commands = false,
      workspaces = {
        { name = 'Obsidian', path = '~/dev/Obsidian' },
      },
      frontmatter = { enabled = false },
    },
  },
}

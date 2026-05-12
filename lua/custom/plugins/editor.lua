return {
  'NMAC427/guess-indent.nvim',
  'tpope/vim-endwise',
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
      vim.keymap.set('n', '<leader>c', '<Plug>(comment_toggle_linewise_current)', { desc = 'Toggle comment line' })
      vim.keymap.set('x', '<leader>c', '<Plug>(comment_toggle_linewise_visual)', { desc = 'Toggle comment selection' })
    end,
  },
}

return {
  {
    'vim-test/vim-test',
    dependencies = {
      'preservim/vimux',
    },
    keys = {
      { '<leader>vn', ':TestNearest<CR>', desc = 'Run nearest test' },
      { '<leader>vf', ':TestFile<CR>', desc = 'Run test file' },
      {
        '<leader>vb',
        function()
          vim.fn['test#strategy#vimux'] 'brake'
        end,
        desc = 'Run brake',
      },
    },
    config = function()
      vim.g['test#strategy'] = 'vimux'
    end,
  },
}

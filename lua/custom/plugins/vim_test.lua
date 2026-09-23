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
          vim.fn['test#shell']('brake', vim.g['test#strategy'])
        end,
        desc = 'Run brake',
      },
    },
    config = function()
      vim.g['test#custom_strategies'] = {
        herdr = require('custom.herdr_test').strategy,
      }
      -- vimux hard-requires $TMUX; herdr replaced tmux as the multiplexer here.
      vim.g['test#strategy'] = vim.env.HERDR_ENV and 'herdr' or 'vimux'
    end,
  },
}

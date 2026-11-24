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
        tuios = require('custom.tuios_test').strategy,
      }
      -- vimux hard-requires $TMUX, which neither herdr nor tuios sets.
      -- tuios wins when both are present, matching the <C-h/j/k/l> setup.
      if vim.env.TUIOS_ENV == '1' and vim.env.TUIOS_PANE_ID then
        vim.g['test#strategy'] = 'tuios'
      elseif vim.env.HERDR_ENV then
        vim.g['test#strategy'] = 'herdr'
      else
        vim.g['test#strategy'] = 'vimux'
      end
    end,
  },
}

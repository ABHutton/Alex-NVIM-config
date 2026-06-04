return {
  {
    'xTacobaco/cursor-agent.nvim',
    config = function()
      vim.keymap.set('n', '<leader>aa', ':CursorAgent<CR>', { desc = 'Cursor Agent: Toggle terminal' })
      vim.keymap.set('v', '<leader>as', ':CursorAgentSelection<CR>', { desc = 'Cursor Agent: Send selection' })
      vim.keymap.set('n', '<leader>ab', ':CursorAgentBuffer<CR>', { desc = 'Cursor Agent: Send buffer' })
      vim.keymap.set('n', '<leader>ap', function()
        require('cursor-agent').ask {
          prompt = 'Use the current project as context. Inspect the repository before answering.',
          title = 'Project Context -> Cursor Agent',
        }
      end, { desc = 'Cursor Agent: Project context prompt' })

      vim.api.nvim_create_autocmd('TermOpen', {
        pattern = 'term://*cursor-agent*',
        callback = function(args)
          vim.keymap.set('t', '<Esc><Esc>', function()
            vim.api.nvim_win_close(0, true)
          end, { buffer = args.buf, desc = 'Cursor Agent: Close terminal' })
        end,
      })
    end,
  },
}

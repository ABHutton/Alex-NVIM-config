return {
  {
    'tpope/vim-obsession',
    lazy = false,
    config = function()
      vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos'

      local obsession = vim.api.nvim_create_augroup('obsession_autosave', { clear = true })

      local function start_obsession()
        if vim.fn.exists('g:SessionLoad') == 1 or vim.fn.exists('g:this_obsession') == 1 then
          return
        end

        vim.cmd 'silent! Obsession'
      end

      vim.api.nvim_create_autocmd('VimEnter', {
        group = obsession,
        desc = 'Start obsession session tracking',
        callback = function()
          vim.schedule(start_obsession)
        end,
      })

      vim.api.nvim_create_autocmd('DirChanged', {
        group = obsession,
        desc = 'Start obsession after changing directory',
        callback = start_obsession,
      })
    end,
  },
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

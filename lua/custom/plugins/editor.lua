return {
  {
    'tpope/vim-obsession',
    lazy = false,
    config = function()
      vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos'

      local obsession = vim.api.nvim_create_augroup('obsession_autosave', { clear = true })

      local function is_real_buffer(buf)
        return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == '' and vim.api.nvim_buf_get_name(buf) ~= ''
      end

      local function any_real_buffer()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if is_real_buffer(buf) then
            return true
          end
        end
        return false
      end

      --- `:Obsession` runs `mksession!` straight away, so tracking may only start once a
      --- real file is open; starting it on the empty dashboard would overwrite a saved
      --- session before the dashboard's restore key gets a chance to source it.
      local function start_obsession()
        if vim.fn.exists('g:SessionLoad') == 1 or vim.fn.exists('g:this_obsession') == 1 then
          return
        end

        if not any_real_buffer() then
          return
        end

        vim.cmd 'silent! Obsession'
      end

      vim.api.nvim_create_autocmd({ 'VimEnter', 'BufReadPost', 'BufNewFile', 'BufWritePost', 'DirChanged' }, {
        group = obsession,
        desc = 'Start obsession session tracking once a real buffer is open',
        callback = function()
          vim.schedule(start_obsession)
        end,
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

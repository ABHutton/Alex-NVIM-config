local sql_ft = { 'sql', 'mysql', 'plsql' }

return {
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true, cmd = 'DB' },
      { 'kristijanhusak/vim-dadbod-completion', ft = sql_ft, lazy = true },
    },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    init = function()
      local data_path = vim.fn.stdpath 'data'

      vim.g.db_ui_use_nerd_fonts = vim.g.have_nerd_font and 1 or 0
      vim.g.db_ui_show_database_icon = vim.g.have_nerd_font
      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_use_nvim_notify = true
      vim.g.db_ui_save_location = data_path .. '/dadbod_ui'
      vim.g.db_ui_tmp_query_location = data_path .. '/dadbod_ui/tmp'

      -- Add connection strings here, e.g.:
      vim.g.dbs = {
        nspack_gr = 'postgresql://postgres:postgres@localhost:5432/nspack_gr',
        nspack_test = 'postgresql://postgres:postgres@localhost:5432/nspack_test',
      }
    end,
    keys = {
      {
        '<leader>db',
        function()
          require('custom.session').dismiss_dashboard()
          vim.cmd 'DBUIToggle'
        end,
        desc = 'Toggle [D]ata[B]ase UI',
      },
      { '<leader>da', '<cmd>DBUIAddConnection<CR>', desc = '[D]atabase [A]dd connection' },
      { '<leader>df', '<cmd>DBUIFindBuffer<CR>', desc = '[D]atabase [F]ind buffer' },
    },
    config = function()
      local augroup = vim.api.nvim_create_augroup('dadbod', { clear = true })
      local session = require 'custom.session'

      local function close_dbui()
        if vim.fn.bufwinnr 'dbui' ~= -1 then
          vim.fn['db_ui#close']()
        end
      end

      -- DBUI skips nofile buffers (like the Snacks dashboard) when picking a query
      -- window, so it opens a third split. Dismiss the dashboard first.
      vim.api.nvim_create_autocmd('User', {
        group = augroup,
        pattern = 'DBUIOpened',
        callback = function()
          session.dismiss_dashboard()
        end,
      })

      -- Fallback: if a query still lands beside the dashboard, move it over.
      vim.api.nvim_create_autocmd('BufWinEnter', {
        group = augroup,
        callback = function(event)
          if not vim.b[event.buf].dbui_db_key_name then
            return
          end
          if not vim.tbl_contains(sql_ft, vim.bo[event.buf].filetype) then
            return
          end

          local dash_wins = session.dashboard_wins()
          if #dash_wins == 0 then
            return
          end

          local query_win = event.win
          local dash_win = dash_wins[1]
          if query_win == dash_win then
            return
          end

          vim.schedule(function()
            if not vim.api.nvim_win_is_valid(dash_win) or not vim.api.nvim_buf_is_valid(event.buf) then
              return
            end
            vim.api.nvim_win_set_buf(dash_win, event.buf)
            if vim.api.nvim_win_is_valid(query_win) and query_win ~= dash_win then
              pcall(vim.api.nvim_win_close, query_win, false)
            end
            vim.api.nvim_set_current_win(dash_win)
          end)
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = augroup,
        pattern = sql_ft,
        callback = function()
          vim.bo.omnifunc = 'vim_dadbod_completion#omni'
        end,
      })

      -- Snacks notifier can briefly take focus when dadbod shows connection timing
      vim.api.nvim_create_autocmd('BufWinEnter', {
        group = augroup,
        callback = function(event)
          if not vim.b[event.buf].dbui_db_key_name then
            return
          end
          if not vim.tbl_contains(sql_ft, vim.bo[event.buf].filetype) then
            return
          end
          local win = event.win
          vim.schedule(function()
            if not vim.api.nvim_win_is_valid(win) then
              return
            end
            local cur_ft = vim.bo.filetype
            if cur_ft == 'snacks_notif' or cur_ft == 'snacks_notif_history' then
              vim.api.nvim_set_current_win(win)
            end
          end)
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = augroup,
        pattern = 'dbui',
        callback = function(event)
          vim.keymap.set('n', '<Esc><Esc>', '<Plug>(DBUI_Quit)', { buffer = event.buf, desc = 'Close DBUI' })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = augroup,
        pattern = vim.list_extend(vim.deepcopy(sql_ft), { 'dbout' }),
        callback = function(event)
          vim.api.nvim_buf_call(event.buf, function()
            if vim.bo.filetype == 'dbout' or vim.b.dbui_db_key_name then
              vim.keymap.set('n', '<Esc><Esc>', close_dbui, { buffer = event.buf, desc = 'Close DBUI' })
            end
          end)
        end,
      })
    end,
  },

  {
    'saghen/blink.cmp',
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.providers = vim.tbl_extend('force', opts.sources.providers or {}, {
        dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
      })
      opts.sources.per_filetype = vim.tbl_extend('force', opts.sources.per_filetype or {}, {
        sql = { 'lsp', 'dadbod', 'snippets', 'lazydev' },
        mysql = { 'lsp', 'dadbod', 'snippets', 'lazydev' },
        plsql = { 'lsp', 'dadbod', 'snippets', 'lazydev' },
      })
      return opts
    end,
  },
}

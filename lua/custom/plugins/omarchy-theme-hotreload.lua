return {
  {
    name = 'omarchy-theme-hotreload',
    dir = vim.fn.stdpath 'config',
    lazy = false,
    priority = 1001,
    config = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyReload',
        callback = function()
          package.loaded['custom.omarchy-theme'] = nil

          vim.schedule(function()
            require('custom.omarchy-theme').apply()
          end)
        end,
      })
    end,
  },
}

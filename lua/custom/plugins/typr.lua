return {
  {
    'nvzone/typr',
    dependencies = 'nvzone/volt',
    cmd = { 'Typr', 'TyprStats' },
    opts = {
      mappings = function(buf)
        require('custom.typr').attach_close_maps(buf)
      end,
    },
    config = function(_, opts)
      require('typr').setup(opts)

      local typr = require 'custom.typr'

      vim.api.nvim_create_user_command('Typr', typr.open, { force = true })
      vim.api.nvim_create_user_command('TyprStats', typr.open_stats, { force = true })

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('typr_snacks', { clear = true }),
        pattern = { 'typr', 'typrstats' },
        callback = function(event)
          typr.disable_editor_plugins(event.buf)
          typr.attach_close_maps(event.buf)
        end,
      })
    end,
  },
}

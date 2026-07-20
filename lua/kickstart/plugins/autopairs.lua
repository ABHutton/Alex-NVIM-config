-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    map_cr = false,
    enabled = function(buf)
      return not require('custom.typr').is_typr_buffer(buf)
    end,
    disable_filetype = {
      'TelescopePrompt',
      'spectre_panel',
      'snacks_picker_input',
      'typr',
      'typrstats',
    },
  },
}

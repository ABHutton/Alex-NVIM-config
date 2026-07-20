-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    map_cr = false,
    disable_filetype = {
      'TelescopePrompt',
      'spectre_panel',
      'snacks_picker_input',
      'typr',
      'typrstats',
    },
  },
}

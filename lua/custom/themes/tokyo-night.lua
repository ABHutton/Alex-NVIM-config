--- Custom folke/tokyonight.nvim config used when Omarchy theme is Tokyo Night.
--- Omarchy's stock neovim.lua only loads the plugin with default opts; this keeps
--- transparency and style preferences instead.
return {
  plugin = 'folke/tokyonight.nvim',
  colorscheme = 'tokyonight-night',
  opts = {
    transparent = true,
    terminal_colors = true,
    styles = {
      comments = { italic = false },
      sidebars = 'transparent',
      floats = 'transparent',
    },
  },
  priority = 1000,
  custom = true,
}

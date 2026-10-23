return {
  {
    'Tim4c/tuios-nvim-navigator',
    -- Only inside tuios; elsewhere vim_tmux_navigator.lua owns <C-h/j/k/l>.
    -- Pairs with appearance.nvim_navigation and terminal_focus_* = ctrl+h/j/k/l
    -- in ~/.config/tuios/config.toml; the four keys must match on both sides.
    cond = vim.env.TUIOS_ENV == '1',
    lazy = false,
    config = function()
      require('tuios-nvim-navigator').setup {
        keymaps = {
          left = '<C-h>',
          down = '<C-j>',
          up = '<C-k>',
          right = '<C-l>',
        },
      }
    end,
  },
}

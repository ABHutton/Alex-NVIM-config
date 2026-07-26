return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      preset = 'modern',
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>q', group = '[Q]uickfix' },
        { '<leader>x', group = 'e[X]tra' },
        { '<leader>g', group = 'Git[H]ub' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>r', group = '[R]ubocop' },
        { '<leader>o', group = '[O]pen' },
        { '<leader>a', group = '[A]gent' },
        { '<leader>d', group = '[D]atabase' },
        { '<leader>v', group = '[V]im Test' },
        { '<leader>m', group = '[M]ulti-cursor' },
      },
    },
  },
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        transparent = true,
        terminal_colors = true,
        styles = {
          comments = { italic = false },
          sidebars = 'transparent',
          floats = 'transparent',
        },
      }
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    event = 'VeryLazy',
    opts = {
      options = {
        theme = 'tokyonight-night',
        icons_enabled = vim.g.have_nerd_font,
        globalstatus = true,
        component_separators = '',
        section_separators = '',
        disabled_filetypes = {
          statusline = { 'dashboard', 'snacks_dashboard' },
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 3 } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { '%2l:%-2v' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 3 } },
        lualine_x = { '%2l:%-2v' },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { 'lazy', 'mason', 'quickfix' },
    },
  },
  {
    'sphamba/smear-cursor.nvim',
    opts = {
      smear_insert_mode = false,

      -- Shorter, snappier smear in normal/visual modes
      max_length = 12,
      min_horizontal_distance_smear = 1,
      min_vertical_distance_smear = 1,
      stiffness = 0.75,
      trailing_stiffness = 0.55,
      damping = 0.9,
      distance_stop_animating = 0.3,
    },
  },
}

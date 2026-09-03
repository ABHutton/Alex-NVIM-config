local ensure_parsers = {
  'bash',
  'c',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'sql',
  'vim',
  'vimdoc',
  'ruby',
}

local is_modern = vim.fn.has 'nvim-0.12' == 1

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = is_modern and 'main' or 'master',
    lazy = false,
    build = ':TSUpdate',
    main = is_modern and nil or 'nvim-treesitter.configs',
    opts = is_modern and {
      install_dir = vim.fn.stdpath 'data' .. '/site',
    } or {
      ensure_installed = ensure_parsers,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    config = is_modern
        and function(_, opts)
          local ts = require 'nvim-treesitter'
          ts.setup(opts)

          local missing = vim.tbl_filter(function(lang)
            return not vim.tbl_contains(ts.get_installed(), lang)
          end, ensure_parsers)

          -- Install missing parsers in the background. Never :wait() here — that
          -- blocks the UI (and a failing download like sql can freeze Neovim).
          if #missing > 0 then
            vim.defer_fn(function()
              ts.install(missing)
            end, 1000)
          end
        end
      or nil,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      enable = true,
      max_lines = 10,
      line_numbers = true,
      trim_scope = 'outer',
      mode = 'cursor',
    },
  },
}

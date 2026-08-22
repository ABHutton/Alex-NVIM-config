return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- Only load if Neovim is older than 0.12
    cond = function()
      return vim.fn.has 'nvim-0.12' == 0
    end,
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'sql', 'vim', 'vimdoc', 'ruby' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    -- Dynamically set the dependency so it doesn't try to load the archived plugin in 0.12+
    dependencies = vim.fn.has 'nvim-0.12' == 0 and { 'nvim-treesitter/nvim-treesitter' } or {},
    opts = {
      enable = true,
      max_lines = 10,
      line_numbers = true,
      trim_scope = 'outer',
      mode = 'cursor',
    },
  },
}

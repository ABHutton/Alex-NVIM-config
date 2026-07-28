return {
  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
    init = function()
      -- Disable default maps; herdr nav owns <C-h/j/k/l> and falls back to
      -- TmuxNavigate* when $TMUX is set and you're not in a herdr pane.
      vim.g.tmux_navigator_no_mappings = 1
    end,
    config = function()
      local matches = vim.fn.glob(
        vim.fn.expand '~/.config/herdr/plugins/github/vim-herdr-navigation-*/editor/nvim.lua',
        false,
        true
      )
      if matches[1] then
        dofile(matches[1])
        return
      end

      -- Fallback if the herdr plugin isn't installed: plain tmux navigator maps.
      local map = vim.keymap.set
      map('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', { silent = true })
      map('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>', { silent = true })
      map('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>', { silent = true })
      map('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', { silent = true })
    end,
  },
}

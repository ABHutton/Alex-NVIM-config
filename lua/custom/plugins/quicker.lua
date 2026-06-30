return {
  'stevearc/quicker.nvim',
  ft = 'qf',
  ---@type quicker.SetupOptions
  opts = {
    edit = {
      enabled = true,
      autosave = 'unmodified',
    },
    keys = {
      {
        '>',
        function()
          require('quicker').expand { before = 2, after = 2, add_to_existing = true }
        end,
        desc = 'Expand quickfix context',
      },
      {
        '<',
        function()
          require('quicker').collapse()
        end,
        desc = 'Collapse quickfix context',
      },
    },
  },
  config = function(_, opts)
    require('quicker').setup(opts)

    vim.keymap.set('n', '<leader>q', function()
      require('quicker').toggle()
    end, { desc = 'Toggle [Q]uickfix' })

    vim.keymap.set('n', '<leader>l', function()
      require('quicker').toggle { loclist = true }
    end, { desc = 'Toggle [L]oclist' })

    -- Former <leader>q: populate diagnostics loclist and open with quicker
    vim.keymap.set('n', '<leader>xd', function()
      vim.diagnostic.setloclist()
      require('quicker').open { loclist = true, focus = true }
    end, { desc = 'Diagnostics loclist' })
  end,
}

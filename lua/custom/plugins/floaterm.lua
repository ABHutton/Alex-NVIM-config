return {
  'nvzone/floaterm',
  dependencies = {
    'nvzone/volt',
  },
  cmd = 'FloatermToggle',

  keys = {
    { '<leader>ot', '<cmd>FloatermToggle<CR>', mode = { 'n' }, desc = '[T]erminal' },
  },

  opts = {
    border = true,
    size = { h = 60, w = 70 },

    terminals = {
      { name = 'Terminal' },
    },

    mappings = {
      sidebar = nil,

      term = function(buf)
        vim.keymap.set({ 't' }, '<Esc><Esc>', '<cmd>FloatermToggle<CR>', { buffer = buf, desc = 'Close Terminal' })

        vim.keymap.set({ 't' }, '<C-p>', function()
          require('floaterm.api').cycle_term_bufs 'prev'
        end, { buffer = buf, desc = 'Floaterm Prev' })

        vim.keymap.set({ 't' }, '<C-n>', function()
          require('floaterm.api').cycle_term_bufs 'next'
        end, { buffer = buf, desc = 'Floaterm Next' })
      end,
    },
  },
}

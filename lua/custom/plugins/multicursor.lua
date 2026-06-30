return {
  {
    'jake-stewart/multicursor.nvim',
    branch = '1.0',
    event = 'VeryLazy',
    config = function()
      local mc = require 'multicursor-nvim'
      mc.setup()

      local set = vim.keymap.set

      set({ 'n', 'x' }, '<leader>mc', function()
        mc.matchAddCursor(1)
      end, { desc = 'Multi-cursor: add next match' })
      set({ 'n', 'x' }, '<leader>mC', function()
        mc.matchAddCursor(-1)
      end, { desc = 'Multi-cursor: add previous match' })
      set({ 'n', 'x' }, '<leader>ms', function()
        mc.matchSkipCursor(1)
      end, { desc = 'Multi-cursor: skip match' })

      set({ 'n', 'x' }, '<Down>', function()
        mc.lineAddCursor(1)
      end, { desc = 'Multi-cursor: line below' })
      set({ 'n', 'x' }, '<Up>', function()
        mc.lineAddCursor(-1)
      end, { desc = 'Multi-cursor: line above' })
      set({ 'n', 'x' }, '<leader><Down>', function()
        mc.lineSkipCursor(1)
      end, { desc = 'Multi-cursor: skip line below' })
      set({ 'n', 'x' }, '<leader><Up>', function()
        mc.lineSkipCursor(-1)
      end, { desc = 'Multi-cursor: skip line above' })

      set('n', '<C-LeftMouse>', mc.handleMouse)
      set('n', '<C-LeftDrag>', mc.handleMouseDrag)
      set('n', '<C-LeftRelease>', mc.handleMouseRelease)

      set({ 'n', 'x' }, '<C-q>', mc.toggleCursor, { desc = 'Multi-cursor: toggle' })

      mc.addKeymapLayer(function(layer)
        layer({ 'n', 'x' }, 'h', mc.prevCursor)
        layer({ 'n', 'x' }, 'l', mc.nextCursor)
        layer({ 'n', 'x' }, '<leader>mx', mc.deleteCursor)
        layer('n', '<Esc>', function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
    end,
  },
}

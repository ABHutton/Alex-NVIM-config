return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    'brianhuster/live-preview.nvim',
    keys = {
      {
        '<leader>op',
        -- Always (re)open rather than toggle: the plugin can't tell when the browser tab was closed,
        -- and LivePreview start shuts down any previous server first
        function()
          -- Ask the OS for a free port so several nvim instances can preview at once
          local tcp = vim.uv.new_tcp()
          tcp:bind('127.0.0.1', 0)
          local port = tcp:getsockname().port
          tcp:close()
          -- Serve from the file's own directory so files outside nvim's cwd don't 404
          require('livepreview.config').set { port = port, dynamic_root = true, sync_scroll = false }
          -- silent: its long "Opening browser at ..." message triggers a hit-enter prompt that blocks the browser launch
          vim.cmd 'silent LivePreview start'
        end,
        desc = 'Markdown [P]review',
      },
      {
        '<leader>oP',
        function()
          if require('livepreview').is_running() then
            vim.cmd 'LivePreview close'
          end
        end,
        desc = 'Stop Markdown [P]review',
      },
    },
  },
  {
    'obsidian-nvim/obsidian.nvim',
    event = { 'BufReadPre ' .. vim.fn.expand '~' .. '/dev/Obsidian/*.md', 'BufNewFile ' .. vim.fn.expand '~' .. '/dev/Obsidian/*.md' },
    opts = {
      legacy_commands = false,
      workspaces = {
        { name = 'Obsidian', path = '~/dev/Obsidian' },
      },
      frontmatter = { enabled = false },
    },
  },
}

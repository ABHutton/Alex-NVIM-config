--- Open Atlas and ensure the detail/preview pane is visible (no upstream config for this).
---@param domain 'pulls'|'issues'
---@param provider string
local function open_with_panel(domain, provider)
  require('atlas').open(domain, provider)
  vim.schedule(function()
    local layout = require 'atlas.ui.layout'
    local ui_state = require 'atlas.ui.state'
    if layout.win_id 'detail' ~= nil then
      return
    end
    layout.toggle_detail()
    if ui_state.on_panel_open then
      ui_state.on_panel_open()
    end
  end)
end

return {
  {
    'emrearmagan/atlas.nvim',
    cmd = {
      'AtlasPulls',
      'AtlasIssues',
      'AtlasDiff',
      'AtlasNotes',
      'AtlasCreatePR',
      'AtlasCreateIssue',
      'AtlasSearch',
      'AtlasOpen',
      'AtlasClearCache',
      'AtlasLogs',
    },
    keys = {
      {
        '<leader>gp',
        function()
          open_with_panel('pulls', 'github')
        end,
        desc = 'Atlas: [P]ull requests',
      },
      {
        '<leader>gj',
        function()
          open_with_panel('issues', 'jira')
        end,
        desc = 'Atlas: [J]ira issues',
      },
      { '<leader>gc', '<cmd>AtlasCreatePR<cr>', desc = 'Atlas: [C]reate pull request' },
      { '<leader>gi', '<cmd>AtlasCreateIssue<cr>', desc = 'Atlas: Create [I]ssue' },
      { '<leader>go', '<cmd>AtlasOpen<cr>', desc = 'Atlas: [O]pen' },
      { '<leader>gn', '<cmd>AtlasNotes<cr>', desc = 'Atlas: [N]otes' },
    },
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      {
        -- Atlas uses this for markdown panes. Without overrides it also paints
        -- normal .md buffers with Nerd Font checkboxes, which fights Obsidian UI.
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          ignore = function(buf)
            local file = vim.api.nvim_buf_get_name(buf)
            return vim.startswith(file, vim.fn.expand '~/dev/Obsidian/Work')
          end,
          checkbox = {
            unchecked = { icon = 'o ' },
            checked = { icon = 'x ' },
          },
        },
      },
    },
    config = function(_, opts)
      require('atlas').setup(opts)

      -- Atlas UI messages go to its statusline by default; mirror warn/error to vim.notify
      -- so Snacks notifier (and :messages) also see them.
      local statusline = require 'atlas.ui.statusline'
      local statusline_notify = statusline.notify
      statusline.notify = function(level, text, duration_ms)
        statusline_notify(level, text, duration_ms)
        if level == 'error' or level == 'warn' then
          vim.notify(tostring(text), level == 'error' and vim.log.levels.ERROR or vim.log.levels.WARN, {
            title = 'Atlas',
          })
        end
      end
    end,
    opts = {
      pulls = {
        diff = {
          open_cmd = 'AtlasDiff',
          layout = 'inline',
          compact = true,
        },
        -- Prefer existing local clones over Atlas's HTTPS cache clone (needs auth and
        -- often fails for private orgs when git is configured for SSH).
        repo_config = {
          paths = {
            ['AgrigateOne/*'] = '~/dev/*',
          },
        },
        providers = {
          github = {
            cache_ttl = 300,
            views = {
              {
                name = 'Review requests',
                key = '1',
                layout = 'plain',
                search = 'is:pr is:open review-requested:@me sort:updated-desc',
              },
              {
                name = 'My PRs',
                key = '2',
                layout = 'plain',
                search = 'is:pr is:open author:@me sort:updated-desc',
              },
              {
                name = 'Involved',
                key = '3',
                layout = 'plain',
                search = 'is:pr is:open involves:@me sort:updated-desc',
              },
            },
            bookmarks = {
              items = {
                ['Drafts'] = 'is:pr is:draft author:@me',
                ['Recently merged'] = 'is:pr is:merged author:@me sort:updated-desc',
              },
            },
          },
        },
      },
      issues = {
        with_relationships = false,
        providers = {
          jira = {
            base_url = vim.env.JIRA_BASE_URL,
            email = vim.env.JIRA_EMAIL,
            token = vim.env.JIRA_API_TOKEN,
            auth_method = 'basic',
            api_type = 'cloud',
            cache_ttl = 300,
            views = {
              {
                name = 'In Progress',
                key = '1',
                layout = 'plain',
                jql = 'assignee = currentUser() AND status = "2. In Progress" AND type != Epic ORDER BY updated DESC',
              },
              {
                name = 'In Review',
                key = '2',
                layout = 'plain',
                jql = 'assignee = currentUser() AND status = "3. In Review" AND type != Epic ORDER BY updated DESC',
              },
              {
                name = 'Assigned',
                key = '3',
                layout = 'plain',
                jql = 'assignee = currentUser() AND statusCategory != Done AND status != "0. Backlog" AND type != Epic ORDER BY updated DESC',
              },
              {
                name = 'Watching',
                key = '4',
                layout = 'plain',
                jql = 'watcher = currentUser() AND statusCategory != Done ORDER BY updated DESC',
              },
              {
                name = 'Mentions (7d)',
                key = '5',
                layout = 'plain',
                jql = 'comment ~ currentUser() AND statusCategory != Done AND updated >= -7d ORDER BY updated DESC',
              },
            },
            bookmarks = {},
          },
        },
      },
    },
  },
}

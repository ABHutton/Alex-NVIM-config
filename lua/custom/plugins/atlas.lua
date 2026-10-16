-- Domains waiting to auto-open the detail/preview pane once their list has loaded.
---@type table<'pulls'|'issues', boolean>
local pending_detail = {}

---@param domain 'pulls'|'issues'
---@param item table|nil a dashboard line_map entry
local function is_detail_item(domain, item)
  if type(item) ~= 'table' then
    return false
  end
  if domain == 'pulls' then
    return (item.kind == 'pr' or item.kind == 'pr_meta') and type(item.pr) == 'table'
  end
  return item.kind == 'issue' and type(item._issue) == 'table'
end

--- Wrap a dashboard's render() so a pending auto-open fires on the first render that has a
--- PR/issue to show. Atlas loads the list asynchronously and emits no "loaded" event, and
--- toggle_detail() is a no-op until the cursor is on an item.
---@param domain 'pulls'|'issues'
local function hook_detail_autoopen(domain)
  local dashboard = require('atlas.' .. domain .. '.ui.dashboard')
  local render = dashboard.render
  dashboard.render = function(...)
    render(...)
    if not pending_detail[domain] then
      return
    end
    if require('atlas.' .. domain .. '.ui.detail').is_open() then
      pending_detail[domain] = nil
      return
    end
    local navigation = require 'atlas.ui.navigation'
    if not is_detail_item(domain, navigation.current_item()) then
      local found = navigation.focus_item(function(item)
        return is_detail_item(domain, item)
      end)
      if not found then
        return -- still loading (or empty view); try again on the next render
      end
    end
    pending_detail[domain] = nil
    vim.schedule(function()
      if not require('atlas.' .. domain .. '.ui.detail').is_open() then
        dashboard.toggle_detail()
      end
    end)
  end
end

--- Open Atlas with the detail/preview pane visible (no upstream config for this).
---@param domain 'pulls'|'issues'
---@param provider string
local function open_with_panel(domain, provider)
  pending_detail[domain] = true
  require('atlas').open(domain, provider)
end

--- Run gh asynchronously; on_done(stdout|nil, err|nil) is called on the main loop.
---@param args string[]
---@param on_done fun(stdout: string|nil, err: string|nil)
local function gh(args, on_done)
  vim.system(vim.list_extend({ 'gh' }, args), { text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        on_done(nil, vim.trim(res.stderr or '') ~= '' and vim.trim(res.stderr) or ('gh exited ' .. res.code))
      else
        on_done(res.stdout, nil)
      end
    end)
  end)
end

--- Atlas custom action: re-request review from people who already submitted one.
--- Atlas's built-in "Edit reviewers" treats approved/changes-requested reviewers as already
--- selected, so it can't re-request them. This POSTs to requested_reviewers directly.
---@type AtlasPullsCustomAction
local rerequest_review = {
  id = 'rerequest_review',
  label = 'Re-request review',
  icon = '󰑐', -- nf-md-refresh (same glyph atlas uses for "retry")
  run = function(pr, _, done)
    if pr.provider ~= 'github' then
      done(false, 'Re-request review is only implemented for GitHub')
      return
    end
    local slug, number = pr.repo_full_name, tostring(pr.id)

    gh({ 'pr', 'view', number, '--repo', slug, '--json', 'author,reviews,reviewRequests' }, function(out, err)
      if err then
        done(false, 'Failed to load reviews: ' .. err)
        return
      end
      local ok, data = pcall(vim.json.decode, out)
      if not ok or type(data) ~= 'table' then
        done(false, 'Failed to parse reviews')
        return
      end

      local pending = {}
      for _, req in ipairs(data.reviewRequests or {}) do
        if req.login then
          pending[req.login] = true
        end
      end
      local author = data.author and data.author.login

      -- Latest non-pending review state per reviewer, in first-review order.
      local latest, order = {}, {}
      for _, review in ipairs(data.reviews or {}) do
        local login = review.author and review.author.login
        if login and login ~= author and not pending[login] and review.state ~= 'PENDING' then
          if not latest[login] then
            table.insert(order, login)
          end
          latest[login] = review.state
        end
      end
      if #order == 0 then
        done(true, 'No past reviewers to re-request')
        return
      end

      local labels = { APPROVED = 'approved', CHANGES_REQUESTED = 'changes requested', COMMENTED = 'commented', DISMISSED = 'dismissed' }
      local items = vim.tbl_map(function(login)
        return { login = login, state = latest[login] }
      end, order)

      require('atlas.ui.picker').multi_select({
        title = string.format('Re-request review for #%s', number),
        items = items,
        selected = {},
        key = function(item)
          return item.login
        end,
        format_item = function(item)
          return string.format('@%s  (%s)', item.login, labels[item.state] or item.state:lower())
        end,
        on_done = function(chosen)
          if #chosen == 0 then
            done(true, 'Cancelled')
            return
          end
          local args = { 'api', '-X', 'POST', string.format('repos/%s/pulls/%s/requested_reviewers', slug, number) }
          local logins = {}
          for _, item in ipairs(chosen) do
            vim.list_extend(args, { '-f', 'reviewers[]=' .. item.login })
            table.insert(logins, '@' .. item.login)
          end
          gh(args, function(_, req_err)
            if req_err then
              done(false, 'Re-request failed: ' .. req_err)
            else
              done(true, 'Re-requested review from ' .. table.concat(logins, ', '))
            end
          end)
        end,
      })
    end)
  end,
}

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
      'MeanderingProgrammer/render-markdown.nvim',
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

      hook_detail_autoopen 'pulls'
      hook_detail_autoopen 'issues'
      -- Don't let a pending auto-open leak into a later session if Atlas closes before loading.
      vim.api.nvim_create_autocmd('User', {
        pattern = 'AtlasUIClosed',
        callback = function()
          pending_detail = {}
        end,
      })
    end,
    opts = {
      providers = {
        github = {
          cache_ttl = 300,
        },
        jira = {
          base_url = vim.env.JIRA_BASE_URL,
          email = vim.env.JIRA_EMAIL,
          token = vim.env.JIRA_API_TOKEN,
          auth_method = 'basic',
          api_type = 'cloud',
          cache_ttl = 300,
        },
      },
      pulls = {
        custom_actions = { rerequest_review },
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
        github = {
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
      issues = {
        with_relationships = false,
        jira = {
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
}

local function file_picker_opts(overrides)
  return vim.tbl_extend('force', {
    hidden = true,
    ignored = true,
  }, overrides or {})
end

local function project_cwd()
  return Snacks.git.get_root(vim.fn.getcwd(0)) or vim.fn.getcwd(0)
end

math.randomseed(vim.uv.hrtime())
local random_hero = math.random(1, 127)

--- ANSI Shadow figlet headers (one per weekday; generated from the same font)
local day_headers = {
  Monday = [[
███╗   ███╗ ██████╗ ███╗   ██╗██████╗  █████╗ ██╗   ██╗
████╗ ████║██╔═══██╗████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔╝
██╔████╔██║██║   ██║██╔██╗ ██║██║  ██║███████║ ╚████╔╝
██║╚██╔╝██║██║   ██║██║╚██╗██║██║  ██║██╔══██║  ╚██╔╝
██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║
╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝]],
  Tuesday = [[
████████╗██╗   ██╗███████╗███████╗██████╗  █████╗ ██╗   ██╗
╚══██╔══╝██║   ██║██╔════╝██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
   ██║   ██║   ██║█████╗  ███████╗██║  ██║███████║ ╚████╔╝
   ██║   ██║   ██║██╔══╝  ╚════██║██║  ██║██╔══██║  ╚██╔╝
   ██║   ╚██████╔╝███████╗███████║██████╔╝██║  ██║   ██║
   ╚═╝    ╚═════╝ ╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝]],
  Wednesday = [[
██╗    ██╗███████╗██████╗ ███╗   ██╗███████╗███████╗██████╗  █████╗ ██╗   ██╗
██║    ██║██╔════╝██╔══██╗████╗  ██║██╔════╝██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
██║ █╗ ██║█████╗  ██║  ██║██╔██╗ ██║█████╗  ███████╗██║  ██║███████║ ╚████╔╝
██║███╗██║██╔══╝  ██║  ██║██║╚██╗██║██╔══╝  ╚════██║██║  ██║██╔══██║  ╚██╔╝
╚███╔███╔╝███████╗██████╔╝██║ ╚████║███████╗███████║██████╔╝██║  ██║   ██║
 ╚══╝╚══╝ ╚══════╝╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝]],
  Thursday = [[
████████╗██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗  █████╗ ██╗   ██╗
╚══██╔══╝██║  ██║██║   ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
   ██║   ███████║██║   ██║██████╔╝███████╗██║  ██║███████║ ╚████╔╝
   ██║   ██╔══██║██║   ██║██╔══██╗╚════██║██║  ██║██╔══██║  ╚██╔╝
   ██║   ██║  ██║╚██████╔╝██║  ██║███████║██████╔╝██║  ██║   ██║
   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝]],
  Friday = [[
███████╗██████╗ ██╗██████╗  █████╗ ██╗   ██╗
██╔════╝██╔══██╗██║██╔══██╗██╔══██╗╚██╗ ██╔╝
█████╗  ██████╔╝██║██║  ██║███████║ ╚████╔╝
██╔══╝  ██╔══██╗██║██║  ██║██╔══██║  ╚██╔╝
██║     ██║  ██║██║██████╔╝██║  ██║   ██║
╚═╝     ╚═╝  ╚═╝╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝]],
  Saturday = [[
███████╗ █████╗ ████████╗██╗   ██╗██████╗ ██████╗  █████╗ ██╗   ██╗
██╔════╝██╔══██╗╚══██╔══╝██║   ██║██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝
███████╗███████║   ██║   ██║   ██║██████╔╝██║  ██║███████║ ╚████╔╝
╚════██║██╔══██║   ██║   ██║   ██║██╔══██╗██║  ██║██╔══██║  ╚██╔╝
███████║██║  ██║   ██║   ╚██████╔╝██║  ██║██████╔╝██║  ██║   ██║
╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝]],
  Sunday = [[
███████╗██╗   ██╗███╗   ██╗██████╗  █████╗ ██╗   ██╗
██╔════╝██║   ██║████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔╝
███████╗██║   ██║██╔██╗ ██║██║  ██║███████║ ╚████╔╝
╚════██║██║   ██║██║╚██╗██║██║  ██║██╔══██║  ╚██╔╝
███████║╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║
╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝]],
}

--- Strip shared leading whitespace; return per-row extra indent removed (for layout restore).
local function strip_figlet_lines(art)
  local lines = vim.split(art:gsub('\n$', ''), '\n', { plain = true })
  local min_lead = math.huge
  for _, line in ipairs(lines) do
    local lead = line:find '%S'
    if lead then
      min_lead = math.min(min_lead, lead - 1)
    end
  end
  if min_lead == math.huge then
    min_lead = 0
  end
  local stripped = {}
  for i, line in ipairs(lines) do
    local lead = line:find '%S'
    if lead then
      stripped[i] = lead - 1 - min_lead
      lines[i] = line:sub(lead - min_lead)
    else
      stripped[i] = 0
    end
  end
  return lines, stripped
end

local function max_day_header_width()
  local max_w = 0
  for _, art in pairs(day_headers) do
    local lines = strip_figlet_lines(art)
    for _, line in ipairs(lines) do
      max_w = math.max(max_w, vim.api.nvim_strwidth(line))
    end
  end
  return max_w
end

local day_header_width = max_day_header_width()

local function figlet_leading_spaces(line)
  local lead = line:find '%S'
  return lead and (lead - 1) or 0
end

--- Tuesday/Thursday ANSI Shadow rows 3-6 are indented 3 spaces in the source art.
local function uses_thursday_layout(raw_art)
  local lines = vim.split(raw_art:gsub('\n$', ''), '\n', { plain = true })
  if #lines < 6 then
    return false
  end
  return figlet_leading_spaces(lines[1]) == 0 and figlet_leading_spaces(lines[2]) == 0 and figlet_leading_spaces(lines[3]) == 3
end

--- Pad figlet rows to a shared width before centering in the dashboard.
local function layout_figlet_lines(lines, dashboard_width, raw_art, stripped)
  local max_w = 0
  for _, line in ipairs(lines) do
    max_w = math.max(max_w, vim.api.nvim_strwidth(line))
  end
  if uses_thursday_layout(raw_art) then
    local max_pl = 0
    for _, line in ipairs(lines) do
      local extra = max_w - vim.api.nvim_strwidth(line)
      max_pl = math.max(max_pl, math.floor(extra / 2))
    end
    for i, line in ipairs(lines) do
      local extra = max_w - vim.api.nvim_strwidth(line)
      local pl = math.min(max_pl, extra)
      lines[i] = string.rep(' ', pl) .. line .. string.rep(' ', extra - pl)
    end
  else
    -- Center only the top ~3/5 of rows; left-align the rest (Friday's row 4 was still pl=1).
    local center_rows = math.floor(#lines * 3 / 5)
    for i, line in ipairs(lines) do
      local extra = max_w - vim.api.nvim_strwidth(line)
      local pl = (i <= center_rows and math.floor(extra / 2) or 0) + (stripped[i] or 0)
      pl = math.min(pl, extra)
      lines[i] = string.rep(' ', pl) .. line .. string.rep(' ', extra - pl)
    end
  end
  local block_pad = dashboard_width - max_w
  local bl = math.floor(block_pad / 2)
  local br = block_pad - bl
  for i, line in ipairs(lines) do
    lines[i] = string.rep(' ', bl) .. lines[i] .. string.rep(' ', br)
  end
  return table.concat(lines, '\n')
end

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  dependencies = {
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    indent = { enabled = true },
    explorer = {
      enabled = true,
      replace_netrw = false,
    },
    dashboard = {
      enabled = true,
      width = day_header_width,
      formats = {
        header = { '%s', align = 'left' },
      },
      sections = {
        function(self)
          local raw_art = day_headers[os.date '%A'] or day_headers.Monday
          local lines, stripped = strip_figlet_lines(raw_art)
          return { header = layout_figlet_lines(lines, self.opts.width, raw_art, stripped), padding = 2 }
        end,
        { section = 'keys', gap = 1 },
        {
          section = 'terminal',
          cmd = string.format('cat ~/.config/nvim/dota_ascii/%d.txt', random_hero),
          align = 'left',
          indent = 13,
          height = 22,
        },
        { section = 'startup', padding = { 0, 2 } },
      },
    },
    terminal = {
      enabled = true,
      win = {
        style = 'terminal',
        position = 'float',
        width = 0.9,
        height = 0.9,
        border = true,
      },
    },
    lazygit = {
      enabled = true,
      configure = true,
      config = {
        os = { editPreset = 'nvim-remote' },
        gui = { nerdFontsVersion = '3' },
      },
    },
    gh = {},
    picker = {
      enabled = true,
      ui_select = true,
      layout = {
        preset = 'telescope',
      },
      formatters = {
        file = {
          min_width = 9999,
          filename_only = false,
        },
      },
      config = function(opts)
        local root = project_cwd()
        opts.cwd = root
        if (opts.finder == 'files' or opts.finder == 'grep') and not opts.buffers and not opts.rtp and not (opts.dirs and #opts.dirs > 0) then
          opts.dirs = { root }
        end
        return opts
      end,
      sources = {
        files = file_picker_opts(),
        explorer = vim.tbl_extend('force', file_picker_opts(), {
          formatters = {
            file = { filename_only = false },
          },
        }),
      },
      actions = {
        delete_file = function(picker)
          local items = picker:selected { fallback = true }
          if #items == 0 then
            return
          end
          local paths = vim.tbl_map(function(item)
            return Snacks.picker.util.path(item)
          end, items)
          local msg = #paths == 1 and ('Delete %s?'):format(paths[1]) or ('Delete %d files?'):format(#paths)
          Snacks.picker.util.confirm(msg, function()
            for _, path in ipairs(paths) do
              if path and vim.fn.confirm('Delete ' .. path .. '?', '&Yes\n&No', 2) == 1 then
                vim.fn.delete(path)
                vim.notify('Deleted ' .. path)
              end
            end
            picker:refresh()
          end)
        end,
      },
      win = {
        list = {
          keys = {
            dd = 'delete_file',
          },
        },
      },
    },
  },
  config = function(_, opts)
    local snacks = require 'snacks'
    snacks.setup(opts)

    -- LSP progress via snacks notifier (fidget uses its own UI, not vim.notify)
    ---@type table<number, { token: lsp.ProgressToken, msg: string, done: boolean }[]>
    local lsp_progress = vim.defaulttable(function()
      return {}
    end)
    vim.api.nvim_create_autocmd('LspProgress', {
      group = vim.api.nvim_create_augroup('snacks-lsp-progress', { clear = true }),
      ---@param ev { data: { client_id: integer, params: lsp.ProgressParams } }
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local value = ev.data.params.value --[[@as { percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end" }]]
        if not client or type(value) ~= 'table' then
          return
        end
        local p = lsp_progress[client.id]
        for i = 1, #p + 1 do
          if i == #p + 1 or p[i].token == ev.data.params.token then
            p[i] = {
              token = ev.data.params.token,
              msg = ('[%3d%%] %s%s'):format(
                value.kind == 'end' and 100 or value.percentage or 100,
                value.title or '',
                value.message and (' **%s**'):format(value.message) or ''
              ),
              done = value.kind == 'end',
            }
            break
          end
        end
        local msg = {} ---@type string[]
        lsp_progress[client.id] = vim.tbl_filter(function(v)
          return table.insert(msg, v.msg) or not v.done
        end, p)
        local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
        vim.notify(table.concat(msg, '\n'), vim.log.levels.INFO, {
          id = 'lsp_progress',
          title = client.name,
          opts = function(notif)
            notif.icon = #lsp_progress[client.id] == 0 and ' ' or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
      end,
    })

    local picker = snacks.picker

    vim.keymap.set('n', '<leader>sh', function()
      picker.help()
    end, { desc = '[S]earch [H]elp' })

    vim.keymap.set('n', '<leader>sk', function()
      picker.keymaps()
    end, { desc = '[S]earch [K]eymaps' })

    vim.keymap.set('n', '<leader>sf', function()
      picker.files(file_picker_opts())
    end, { desc = '[S]earch [F]iles' })

    vim.keymap.set('n', '<leader>ss', function()
      picker()
    end, { desc = '[S]earch [S]elect Telescope' })

    vim.keymap.set('n', '<leader>sw', function()
      picker.grep_word()
    end, { desc = '[S]earch current [W]ord' })

    vim.keymap.set('n', '<leader>sg', function()
      picker.grep()
    end, { desc = '[S]earch by [G]rep' })

    vim.keymap.set('n', '<leader>sd', function()
      picker.diagnostics()
    end, { desc = '[S]earch [D]iagnostics' })

    vim.keymap.set('n', '<leader>sr', function()
      picker.resume()
    end, { desc = '[S]earch [R]esume' })

    vim.keymap.set('n', '<leader>s.', function()
      picker.recent()
    end, { desc = '[S]earch Recent Files ("." for repeat)' })

    vim.keymap.set('n', '<leader><leader>', function()
      picker.buffers()
    end, { desc = '[ ] Find existing buffers' })

    vim.keymap.set('n', '<leader>ov', '<cmd>vsplit<CR>', { desc = '[S]plit [V]ertically' })
    vim.keymap.set('n', '<leader>oh', '<cmd>split<CR>', { desc = '[S]plit [H]orizontally' })

    vim.keymap.set('n', '<leader>/', function()
      picker.lines {
        layout = 'dropdown',
        preview = false,
      }
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>s/', function()
      picker.grep_buffers()
    end, { desc = '[S]earch [/] in Open Files' })

    vim.keymap.set('n', '<leader>sn', function()
      picker.files(file_picker_opts { cwd = vim.fn.stdpath 'config' })
    end, { desc = '[S]earch [N]eovim files' })

    vim.keymap.set('n', '<leader>ot', function()
      snacks.terminal.toggle()
    end, { desc = '[T]erminal' })

    vim.keymap.set('n', '<leader>og', function()
      snacks.lazygit.open()
    end, { desc = 'Lazy[G]it' })

    vim.keymap.set('n', '<leader>gi', function()
      picker.gh_issue()
    end, { desc = 'GitHub [I]ssues (open)' })

    vim.keymap.set('n', '<leader>gI', function()
      picker.gh_issue { state = 'all' }
    end, { desc = 'GitHub [I]ssues (all)' })

    vim.keymap.set('n', '<leader>gp', function()
      picker.gh_pr()
    end, { desc = 'GitHub [P]ull Requests (open)' })

    vim.keymap.set('n', '<leader>gP', function()
      picker.gh_pr { state = 'all' }
    end, { desc = 'GitHub [P]ull Requests (all)' })

    vim.keymap.set('n', '\\', function()
      local explorer = picker.get({ source = 'explorer' })[1]
      if explorer then
        explorer:close()
      else
        snacks.explorer.reveal()
      end
    end, { desc = 'Explorer toggle', silent = true })

    vim.api.nvim_create_autocmd('TermOpen', {
      callback = function(event)
        if vim.bo[event.buf].filetype ~= 'snacks_terminal' then
          return
        end
        vim.keymap.set({ 'n', 't' }, '<Esc><Esc>', function()
          local win = vim.api.nvim_get_current_win()
          local snacks_win = vim.w[win].snacks_win
          if snacks_win and snacks_win.hide then
            snacks_win:hide()
          elseif snacks.terminal.get(nil, { create = false }) then
            snacks.terminal.focus()
          end
        end, { buffer = event.buf, desc = 'Close Terminal' })
      end,
    })
  end,
}

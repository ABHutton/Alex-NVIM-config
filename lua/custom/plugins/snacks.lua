local function file_picker_opts(overrides)
  return vim.tbl_extend('force', {
    hidden = true,
    ignored = true,
  }, overrides or {})
end

--- ANSI Shadow figlet headers (one per weekday)
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

--- Strip figlet's per-row leading spaces so the glyph block shares one left edge.
local function strip_figlet_lines(art)
  local lines = vim.split(art:gsub('\n$', ''), '\n', { plain = true })
  local min_lead = math.huge
  for _, line in ipairs(lines) do
    local lead = line:find('%S')
    if lead then
      min_lead = math.min(min_lead, lead - 1)
    end
  end
  if min_lead == math.huge then
    min_lead = 0
  end
  for i, line in ipairs(lines) do
    local lead = line:find('%S')
    if lead then
      lines[i] = line:sub(lead - min_lead)
    end
  end
  return lines
end

local function max_day_header_width()
  local max_w = 0
  for _, art in pairs(day_headers) do
    for _, line in ipairs(strip_figlet_lines(art)) do
      max_w = math.max(max_w, vim.api.nvim_strwidth(line))
    end
  end
  return max_w
end

local day_header_width = max_day_header_width()

--- Pad figlet rows to a shared width; use the deepest left pad so tapered rows line up.
local function layout_figlet_lines(lines, dashboard_width)
  local max_w = 0
  for _, line in ipairs(lines) do
    max_w = math.max(max_w, vim.api.nvim_strwidth(line))
  end
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
          local lines = strip_figlet_lines(day_headers[os.date '%A'] or day_headers.Monday)
          return { header = layout_figlet_lines(lines, self.opts.width), padding = 2 }
        end,
        { section = 'keys', gap = 1 },
        { section = 'startup', padding = { 0, 2 } },
      },
    },
    terminal = {
      enabled = true,
      win = {
        style = 'terminal',
        width = 0.7,
        height = 0.6,
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
    picker = {
      enabled = true,
      ui_select = true,
      layout = {
        preset = 'telescope',
      },
      sources = {
        files = file_picker_opts(),
        explorer = file_picker_opts(),
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

    vim.keymap.set('n', '\\', function()
      local current = picker.current
      if current and current.opts.source == 'explorer' then
        current:close()
      else
        snacks.explorer.reveal()
      end
    end, { desc = 'NeoTree reveal', silent = true })

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

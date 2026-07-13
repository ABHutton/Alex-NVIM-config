return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', function()
            Snacks.picker.lsp_references()
          end, '[G]oto [R]eferences')
          map('gri', function()
            Snacks.picker.lsp_implementations()
          end, '[G]oto [I]mplementation')
          map('grd', function()
            Snacks.picker.lsp_definitions()
          end, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', function()
            Snacks.picker.lsp_symbols()
          end, 'Open Document Symbols')
          map('gW', function()
            Snacks.picker.lsp_workspace_symbols()
          end, 'Open Workspace Symbols')
          map('grt', function()
            Snacks.picker.lsp_type_definitions()
          end, '[G]oto [T]ype Definition')
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end

          -- Ruby LSP indexes declarations as part of codeLens/foldingRange requests.
          -- Neovim does not send those automatically, so grd/grr stay stale until restart.
          -- See: https://github.com/Shopify/ruby-lsp/issues/3384
          if
            client
            and client.name == 'ruby_lsp'
            and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_codeLens, event.buf)
          then
            local refresh_index = function()
              vim.lsp.codelens.refresh { bufnr = event.buf }
            end
            vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
              buffer = event.buf,
              group = vim.api.nvim_create_augroup('ruby-lsp-index', { clear = false }),
              callback = refresh_index,
            })
            vim.schedule(refresh_index)
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      local protocol = require 'vim.lsp.protocol'
      vim.lsp.handlers['window/showMessage'] = function(err, result, ctx)
        if err then
          if err.code ~= protocol.ErrorCodes.ContentModified then
            local client = vim.lsp.get_client_by_id(ctx.client_id)
            local client_name = client and client.name or ('client_id=' .. ctx.client_id)
            vim.notify(
              client_name .. ': ' .. tostring(err.code) .. ': ' .. err.message,
              vim.log.levels.ERROR,
              { title = 'LSP' }
            )
          end
          return
        end
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        local client_name = client and client.name or ('id=' .. ctx.client_id)
        if not client then
          vim.notify(
            ('LSP[%s] client has shut down after sending the message'):format(client_name),
            vim.log.levels.ERROR,
            { title = 'LSP' }
          )
          return result
        end
        local level = ({
          [protocol.MessageType.Error] = vim.log.levels.ERROR,
          [protocol.MessageType.Warning] = vim.log.levels.WARN,
          [protocol.MessageType.Info] = vim.log.levels.INFO,
          [protocol.MessageType.Log] = vim.log.levels.INFO,
        })[result.type] or vim.log.levels.INFO
        vim.notify(result.message, level, { title = client_name })
        return result
      end

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        ruby_lsp = {
          cmd = { 'ruby-lsp' },
          filetypes = { 'ruby', 'eruby' },
          init_options = {
            formatter = 'auto',
          },
          root_markers = { 'Gemfile', '.git' },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
      }
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
        'markdownlint',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
  {
    'nvim-java/nvim-java',
    config = function()
      require('java').setup {
        spring_boot_tools = {
          enable = false,
        },
        -- Uncomment if springboot is required
        -- jdk = {
        --   args = { '-XX:+UnlockExperimentalVMOptions' },
        -- },
      }
      vim.lsp.enable 'jdtls'
    end,
  },
}

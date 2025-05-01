--------------------------------------------------------------------------------
--  Basic LSP configuration – no Lazy, no Mason
--  Depends on:
--    • neovim/nvim-lspconfig
--    • j-hui/fidget.nvim            (optional status UI)
--    • folke/neodev.nvim            (improved Lua-LS for Neovim APIs)
--------------------------------------------------------------------------------

-- OPTIONAL UI EXTRAS ----------------------------------------------------------
require('fidget').setup({})
require('lazydev').setup({})

-- ON-ATTACH: keymaps & highlighting ------------------------------------------
local on_attach = function(_, bufnr)
  local map = function(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  map('K', vim.lsp.buf.hover, 'Hover Docs')
  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
end
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my-lsp-attach', { clear = true }),
  callback = function(event)
    local bufnr = event.buf

    --------------------------------------------------------------------------
    -- Highlight references while the cursor is idle
    --------------------------------------------------------------------------
    -- v0.10+ API: returns *all* clients attached to this buffer
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
      if client.server_capabilities.documentHighlightProvider then
        -- highlight on CursorHold / CursorHoldI
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = bufnr,
          callback = vim.lsp.buf.document_highlight,
        })
        -- clear highlights when the cursor moves
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = bufnr,
          callback = vim.lsp.buf.clear_references,
        })
        -- one match is enough; break out
        break
      end
    end
  end,
})
-- CAPABILITIES (adds nvim-cmp completion capability) -------------------------
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if ok_cmp then
  capabilities = vim.tbl_deep_extend('force', capabilities, cmp_lsp.default_capabilities())
end

-- SERVER LIST & PER-SERVER SETTINGS ------------------------------------------
local servers = {
  clangd           = {},
  gopls            = {},
  golangci_lint_ls = {},
  pylsp            = {},
  --  mypy             = {},
  rust_analyzer    = {},
  biome            = {}, -- needs biome executable in PATH
  ts_ls            = {}, -- renamed “ts_ls” → standard id “tsserver”
  terraformls      = {},
  bashls           = {},
  html             = {},
  helm_ls          = {},
  -- htmx             = {}, -- example extra server
  jsonls           = {},
  svelte           = {},
  yamlls           = {},
  cssls            = {},

  lua_ls           = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        workspace = {
          checkThirdParty = false,
          library = {
            '${3rd}/luv/library',
            unpack(vim.api.nvim_get_runtime_file('', true)),
          },
        },
        completion = { callSnippet = 'Replace' },
      },
    },
  },
  tailwindcss      = {}

}

-- INITIALISE EACH SERVER ------------------------------------------------------
local lspconfig = require('lspconfig')

for name, config in pairs(servers) do
  config = vim.tbl_deep_extend('force', {
    on_attach = on_attach,
    capabilities = capabilities,
  }, config or {})

  lspconfig[name].setup(config)
end

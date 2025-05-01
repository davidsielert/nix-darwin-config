--------------------------------------------------------------------------------
--  Basic LSP configuration – no Lazy, no Mason
--  Depends on:
--    • neovim/nvim-lspconfig
--    • j-hui/fidget.nvim            (optional status UI)
--    • folke/neodev.nvim            (improved Lua-LS for Neovim APIs)
--------------------------------------------------------------------------------

-- OPTIONAL UI EXTRAS ----------------------------------------------------------
pcall(require, 'fidget').setup({})
pcall(require, 'neodev').setup({})

-- ON-ATTACH: keymaps & highlighting ------------------------------------------
local on_attach = function(_, bufnr)
  local map = function(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  map('gd', require('telescope.builtin').lsp_definitions,            '[G]oto [D]efinition')
  map('gr', require('telescope.builtin').lsp_references,             '[G]oto [R]eferences')
  map('gI', require('telescope.builtin').lsp_implementations,        '[G]oto [I]mplementation')
  map('<leader>D', require('telescope.builtin').lsp_type_definitions,'Type [D]efinition')
  map('<leader>ds', require('telescope.builtin').lsp_document_symbols,'[D]ocument [S]ymbols')
  map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols,'[W]orkspace [S]ymbols')
  map('<leader>rn', vim.lsp.buf.rename,                              '[R]e[n]ame')
  map('<leader>ca', vim.lsp.buf.code_action,                         '[C]ode [A]ction')
  map('K',        vim.lsp.buf.hover,                                 'Hover Docs')
  map('gD',       vim.lsp.buf.declaration,                           '[G]oto [D]eclaration')

  -- Highlight references while cursor is idle
  local client = vim.lsp.get_client_by_id(vim.lsp.get_client_by_bufnr(bufnr).id)
  if client and client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

-- CAPABILITIES (adds nvim-cmp completion capability) -------------------------
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if ok_cmp then
  capabilities = vim.tbl_deep_extend('force', capabilities, cmp_lsp.default_capabilities())
end

-- SERVER LIST & PER-SERVER SETTINGS ------------------------------------------
local servers = {
  clangd = {},
  gopls  = {},
  golangci_lint_ls = {},
  pylsp  = {},
  mypy   = {},
  rust_analyzer = {},
  biome  = {},        -- needs biome executable in PATH
  tsserver = {},      -- renamed “ts_ls” → standard id “tsserver”
  terraformls = {},
  bashls = {},
  html = {},
  helm_ls = {},
  htmx = {},          -- example extra server
  jsonls = {},
  svelte = {},
  yamlls = {},
  cssls = {},

  lua_ls = {
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
  tailwindcss = {}
  
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

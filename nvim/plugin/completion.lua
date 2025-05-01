if vim.g.did_load_completion_plugin then
  return
end
vim.g.did_load_completion_plugin = true
local cmp                        = require('cmp')
local twcolor                    = require('tailwindcss-colorizer-cmp')
twcolor.setup({
  color_square_width = 2,
})
require('copilot_cmp').setup({}) -- copilot-cmp glue
local lspkind       = require('lspkind')
local lspconfig     = require('lspconfig')
local luasnip       = require('luasnip')
local capabilities  = require('cmp_nvim_lsp').default_capabilities()
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
lspconfig.tailwindcss.setup({
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern(
    'tailwind.config.js',
    'tailwind.config.cjs',
    'tailwind.config.mjs',
    'postcss.config.js',
    'package.json',
    '.git'
  ),
})
local lspkind_format = lspkind.cmp_format({
  mode = 'symbol_text',
  with_text = true,
  maxwidth = 50,
  ellipsis_char = '...',
  menu = {
    buffer                   = '[BUF]',
    nvim_lsp                 = '[LSP]',
    nvim_lsp_signature_help  = '[LSP]',
    nvim_lsp_document_symbol = '[LSP]',
    nvim_lua                 = '[API]',
    path                     = '[PATH]',
    luasnip                  = '[SNIP]',
  },
})
local function has_words_before()
  local unpack_ = unpack or table.unpack
  local line, col = unpack_(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

---@param source string|table
local function complete_with_source(source)
  if type(source) == 'string' then
    cmp.complete { config = { sources = { { name = source } } } }
  elseif type(source) == 'table' then
    cmp.complete { config = { sources = { source } } }
  end
end

cmp.setup {
  completion = {
    completeopt = 'menu,menuone,noinsert',
    -- autocomplete = false,
  },
  formatting = {
    format = function(entry, item)
      item = lspkind_format(entry, item)    -- ① add icons / text
      item = twcolor.formatter(entry, item) -- ② draw colour squares
      return item
    end,
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.scroll_docs(-4)
      else
        complete_with_source('buffer')
      end
    end, { 'i', 'c', 's' }),
    ['<C-f>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.scroll_docs(4)
      else
        complete_with_source('path')
      end
    end, { 'i', 'c', 's' }),
    ['<C-n>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
        -- expand_or_jumpable(): Jump outside the snippet region
        -- expand_or_locally_jumpable(): Only jump inside the snippet region
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 'c', 's' }),
    ['<C-p>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 'c', 's' }),
    -- toggle completion
    ['<C-e>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.close()
      else
        cmp.complete()
      end
    end, { 'i', 'c', 's' }),
    ['<C-y>'] = cmp.mapping.confirm {
      select = true,
    },
  },
  sources = cmp.config.sources {
    -- The insertion order influences the priority of the sources
    { name = 'copilot',                 group_index = 2 }, -- Copilot suggestions
    { name = 'nvim_lsp',                keyword_length = 3 },
    { name = 'nvim_lsp_signature_help', keyword_length = 3 },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'luasnip' }, -- Snippets

  },
  enabled = function()
    return vim.bo[0].buftype ~= 'prompt'
  end,
  experimental = {
    native_menu = false,
    ghost_text = true,
  },
}

cmp.setup.filetype('lua', {
  sources = cmp.config.sources {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'path' },
  },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'nvim_lsp_document_symbol', keyword_length = 3 },
    { name = 'buffer' },
    { name = 'cmdline_history' },
  },
  view = {
    entries = { name = 'wildmenu', separator = '|' },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources {
    { name = 'cmdline' },
    { name = 'cmdline_history' },
    { name = 'path' },
  },
})

vim.keymap.set({ 'i', 'c', 's' }, '<C-n>', cmp.complete, { noremap = false, desc = '[cmp] complete' })
vim.keymap.set({ 'i', 'c', 's' }, '<C-f>', function()
  complete_with_source('path')
end, { noremap = false, desc = '[cmp] path' })
vim.keymap.set({ 'i', 'c', 's' }, '<C-o>', function()
  complete_with_source('nvim_lsp')
end, { noremap = false, desc = '[cmp] lsp' })
vim.keymap.set({ 'c' }, '<C-h>', function()
  complete_with_source('cmdline_history')
end, { noremap = false, desc = '[cmp] cmdline history' })
vim.keymap.set({ 'c' }, '<C-c>', function()
  complete_with_source('cmdline')
end, { noremap = false, desc = '[cmp] cmdline' })


local capabilities = vim.lsp.protocol.make_client_capabilities()

-- safe require: pcall returns (true, module) on success
local ok_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if ok_cmp and cmp_lsp then
  -- default_capabilities() already merges for you
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

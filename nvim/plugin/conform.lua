--------------------------------------------------------------------------------
--  Auto-formatting (conform.nvim) – no Lazy, no Mason
--  Plugin required:  stevearc/conform.nvim
--------------------------------------------------------------------------------
--  Install the plugin with your preferred manager, e.g.
--      use 'stevearc/conform.nvim'      -- packer
--      Plug 'stevearc/conform.nvim'     -- vim-plug
--      lua require('lazy').setup({ { 'stevearc/conform.nvim' } })
--------------------------------------------------------------------------------
local conform = require('conform')

conform.setup {
  -- global options ------------------------------------------------------------
  notify_on_error = false,

  format_on_save = {
    timeout_ms   = 500,
    lsp_fallback = true,
  },

  -- filetype → formatter list -------------------------------------------------
  formatters_by_ft = {
    lua        = { 'stylua' },

    python     = { 'isort', 'black' },

    javascript = { 'biome' }, -- stop_after_first = true  (default behaviour)

    typescript = { 'biome' },
    html       = { 'biome' },
    css        = { 'biome' },
  },

  -- per-formatter overrides ---------------------------------------------------
  formatters = {
    biome = {
      command = 'npx',
      -- `ctx` gives you { buf, file, range = {start,end}|nil, lsp_fallback, … }
      args = function(self, ctx)
        return {
          'biome',
          'format',
          '--stdin-file-path',
          ctx.filename,
        }
      end,
      stdin = true,
    },
  },
}

-- OPTIONAL: keymap to format the current buffer on demand ---------------------
vim.keymap.set('n', '<leader>f', function() conform.format() end,
  { desc = 'Format current buffer with conform.nvim' })

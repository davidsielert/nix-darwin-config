--------------------------------------------------------------------------------
--  Debugging with nvim-dap (no Mason, no Lazy)
--  Required plugins (use any manager you like):
--    • mfussenegger/nvim-dap
--    • rcarriga/nvim-dap-ui
--    • leoluz/nvim-dap-go   -- optional, for Go
--------------------------------------------------------------------------------
local dap   = require('dap')
local dapui = require('dapui')

-------------------------------------------------------------------------------
-- Key-maps
-------------------------------------------------------------------------------
vim.keymap.set('n', '<F5>', dap.continue,          { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F1>', dap.step_into,         { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F2>', dap.step_over,         { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F3>', dap.step_out,          { desc = 'Debug: Step Out'  })
vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'Debug: Set Breakpoint' })

-------------------------------------------------------------------------------
-- DAP-UI
-------------------------------------------------------------------------------
dapui.setup({
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  controls = {
    icons = {
      pause        = '⏸',
      play         = '▶',
      step_into    = '⏎',
      step_over    = '⏭',
      step_out     = '⏮',
      step_back    = 'b',
      run_last     = '▶▶',
      terminate    = '⏹',
      disconnect   = '⏏',
    },
  },
})

vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: Toggle DAP-UI' })

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config']      = dapui.close

-------------------------------------------------------------------------------
-- Adapters / languages
-------------------------------------------------------------------------------
-- 1. Go (requires `dlv` on your PATH)
require('dap-go').setup()

-- 2. If you need additional adapters, configure them manually here.
--    Example for Python with debugpy:
-- dap.adapters.python = {
--   type = 'executable',
--   command = 'python',
--   args = { '-m', 'debugpy.adapter' },
-- }
-- dap.configurations.python = {
--   { type = 'python', request = 'launch', name = 'Launch file',
--     program = '${file}', console = 'integratedTerminal' },
-- }

-- 3. For other languages check :help nvim-dap or the adapter’s README.

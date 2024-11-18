{
  plugins.dap = {
    enable = true;

# Optional: Enable DAP UI for a better debugging experience
    dapui = {
      enable = true;
    };

# Optional: Enable virtual text for DAP
    virtualText = {
      enable = true;
    };

# Additional configuration for DAP
    setup = ''
      local dap = require("dap")
      local dapui = require("dapui")

      -- Automatically open and close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
      end

      -- Configure DAP Adapters
      dap.adapters.lldb = {
        type = "executable",
        command = "/usr/bin/lldb-vscode", -- Adjust the path to lldb-vscode
          name = "lldb"
      }

    -- Configure DAP Configurations
      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        }
      }
    '';
  };
}

{config, ...}:
{
  programs.nixvim.plugins.dap = {
    enable = true;

# Optional: Enable DAP UI for a better debugging experience
    extensions = {
      dap-python = {
        enable = true;
      };
      dap-ui = {
        enable = true;
        floating.mappings = {
          close = [
            "<ESC>"
              "q"
          ];
        };
      };
      dap-virtual-text = {
        enable = true;
      };
    };
    };

}

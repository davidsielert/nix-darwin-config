{
  programs.nvf.settings.vim = {
    visuals = {
      #  enable = true;
      nvim-web-devicons.enable = true;
      nvim-scrollbar.enable = true;
      # smoothScroll.enable = false;
      cellular-automaton.enable = false;
      highlight-undo.enable = true;

      indent-blankline = {
        enable = true;
      };

      nvim-cursorline = {
        enable = true;
        setupOpts.line_timeout = 0;
      };

      fidget-nvim = {
        enable = true;
        setupOpts = {
          notification.window = {
            winblend = 0;
            border = "none";
          };
        };
      };
    };
  };
}

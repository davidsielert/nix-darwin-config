{
  programs.nixvim.plugins.barbar = {
    enable = true;
    keymaps = {

      next.key = "<TAB>";
      previous.key = "<S-TAB>";
      # close = "<C-q>";
    };
  };
}
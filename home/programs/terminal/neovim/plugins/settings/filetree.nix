{
  programs.nvf.settings.vim = {
    filetree = {
      nvimTree = {
        enable = true;
        openOnSetup = false;

        mappings = {
          toggle = "<C-e>";
        };

        setupOpts = {
          disable_netrw = true;
          update_focused_file.enable = true;

          hijack_unnamed_buffer_when_opening = false;
          hijack_cursor = true;
          hijack_directories = {
            enable = false;
            auto_open = false;
          };

          git = {
            enable = true;
            show_on_dirs = false;
            timeout = 500;
          };

          view = {
            cursorline = false;
            width = 35;
          };

          renderer = {
            indent_markers.enable = true;
            root_folder_label = false; # inconsistent

            icons = {
              modified_placement = "after";
              git_placement = "after";
              show.git = true;
              show.modified = true;
            };
          };

          diagnostics.enable = true;

          modified = {
            enable = true;
            show_on_dirs = false;
            show_on_open_dirs = true;
          };

          actions = {
            change_dir.enable = true;
            change_dir.global = true;
            open_file.window_picker.enable = true;
          };
        };
      };
    };
  };
}

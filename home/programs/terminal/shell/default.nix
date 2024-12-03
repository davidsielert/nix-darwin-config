{
  inputs,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    wakatime-cli
  ];
  programs.fish = {
    enable = true;
    #useBabelfish = true;
    plugins = with pkgs; [
      {
        name = "bass";
        src = fishPlugins.bass;
      }
      {
        name = "fzf";
        src = fishPlugins.fzf;
      }
      {
        name = "z";
        src = fishPlugins.z;
      }
      {
        name = "wakatime";
        src = fishPlugins.wakatime-fish;
      }
      {
        name = "kubectl";
        src = pkgs.fetchFromGitHub {
          owner = "blackjid";
          repo = "plugin-kubectl";
          rev = "3f1c96d80014da957bde681ca2f59ade8bf1d423";
          sha256 = "sha256-LZQDqvsqz1jDXAzpIOIKn090e3gQ1ugzk8Bw+xZ2efA=";
        };
      }
      {
        name = "tmux";
        src = pkgs.fetchFromGitHub {
          owner = "budimanjojo";
          repo = "tmux.fish";
          rev = "v2.0.1";
          sha256 = "sha256-ynhEhrdXQfE1dcYsSk2M2BFScNXWPh3aws0U7eDFtv4=";
        };
      }
    ];
    loginShellInit = let
      # We should probably use `config.environment.profiles`, as described in
      # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
      # but this takes into account the new XDG paths used when the nix
      # configuration has `use-xdg-base-directories` enabled. See:
      # https://github.com/LnL7/nix-darwin/issues/947 for more information.
      profiles = [
        "/etc/profiles/per-user/$USER" # Home manager packages
        "$HOME/.nix-profile"
        "(set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo $HOME/.local/state)/nix/profile"
        "/run/current-system/sw"
        "/nix/var/nix/profiles/default"
      ];

      makeBinSearchPath =
        lib.concatMapStringsSep " " (path: "${path}/bin");
    in ''
      # Fix path that was re-ordered by Apple's path_helper
      fish_add_path --move --prepend --path ${makeBinSearchPath profiles}
      set fish_user_paths $fish_user_paths

    '';
    interactiveShellInit = ''
      status is-interactive; and begin
        set fish_tmux_autostart true
      end
    '';
    functions = {
      auto_activate_venv = {
        body = ''
          # Get the top-level directory of the current Git repo (if any)
          set REPO_ROOT (git rev-parse --show-toplevel 2>/dev/null)

          # Case #1: cd'd from a Git repo to a non-Git folder
          #
          # There's no virtualenv to activate, and we want to deactivate any
          # virtualenv which is already active.
          if test -z "$REPO_ROOT"; and test -n "$VIRTUAL_ENV"
              deactivate
          end

          # Case #2: cd'd folders within the same Git repo
          #
          # The virtualenv for this Git repo is already activated, so there's
          # nothing more to do.
          if [ "$VIRTUAL_ENV" = "$REPO_ROOT/.venv" ]
              return
          end

          # Case #3: cd'd from a non-Git folder into a Git repo
          #
          # If there's a virtualenv in the root of this repo, we should
          # activate it now.
          if [ -d "$REPO_ROOT/.venv" ]
              source "$REPO_ROOT/.venv/bin/activate.fish" &>/dev/null
          end
        '';
        description = "Auto-activate virtualenv when changing directories";
        onVariable = "PWD";
      };
    };
  };
  programs.nushell = {
    enable = true;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtraFirst = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      ZSH_TMUX_AUTOSTART=''${ZSH_TMUX_AUTOSTART:-true}
      ZSH_TMUX_AUTOSTART_ONCE=true
      ZSH_TMUX_DEFAULT_SESSION_NAME=main
      DISABLE_AUTO_UPDATE=true
      DISABLE_UPDATE_PROMPT=true

    '';
    #zplug = {
    #  enable = true;
    #  plugins = [
    #    {name = "MichaelAquilina/zsh-autoswitch-virtualenv";}
    #  ];
    #};
    oh-my-zsh = {
      enable = true;
      plugins = [
        "aliases"
        "tmux"
        "virtualenvwrapper"
      ];
    };
    envExtra = ''
      export WORKON_HOME="/Users/davidsielert/.virtualenvs"; # Replace with your desired path
      export VIRTUALENVWRAPPER_PYTHON="${pkgs.python3}/bin/python3"
      export VIRTUALENVWRAPPER_VIRTUALENV="${pkgs.python3Packages.virtualenv}/bin/virtualenv"
    '';
  };

  home.shellAliases = {
    k = "kubectl";
    reload = "source ~/.zshrc";
    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };
  programs.tmux = {
    enable = true;
    # shell = "\${pkgs.zsh}/bin/zsh";
    extraConfig = ''
      set -gu default-command
      set -g default-shell "\${pkgs.fish}/bin/fish"
    '';
    /*
       extraConfig = ''
      #set-option -sa terminal-overrides ",xterm*:Tc"
      set -g xterm-keys on
      set-option -sa terminal-features ',xterm-kitty:RGB'
      #set-environment -g TMUX_PLUGIN_MANAGER_PATH "~/.config/tmux/plugins/"
      set -g mouse on
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      set -s copy-command 'wl-copy'
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on
      #set prefix
      #unbind C-b
      #set -g prefix C-Space
      #bind C-Space send-prefix
      # Join and split panes
      bind-key ! break-pane -d -n _hidden_pane
      bind-key @ join-pane -s $.1
      bind -n M-H previous-window
      bind -n M-L next-window
      set -g @catppuccin_flavour 'mocha'
      # List of plugins
      # set -g @plugin 'tmux-plugins/tpm'
      # set -g @plugin 'tmux-plugins/tmux-sensible'
      # set -g @plugin 'tmux-plugins/tmux-yank'
      # set -g @plugin 'dreamsofcode-io/catppuccin-tmux'
      # :set -g @plugin 'erikw/tmux-powerline'
      # Other examples:

      # set -g @plugin 'github_username/plugin_name'
      # set -g @plugin 'github_username/plugin_name#branch'
      # set -g @plugin 'git@github.com:user/plugin'
      # set -g @plugin 'git@bitbucket.com:user/plugin'


      bind-key -r G run-shell "~/.config/bin/tmux-sessionizer ~/projects/gfndr/"
      bind-key -r f run-shell "tmux neww ~/.config/bin/tmux-sessionizer"
      # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)

      # Smart pane switching with awareness of Vim splits.
      # See: https://github.com/christoomey/vim-tmux-navigator

      # decide whether we're in a Vim process
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'


      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -n 'C-Space' if-shell "$is_vim" 'send-keys C-Space' 'select-pane -t:.+'

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
      bind-key -T copy-mode-vi 'C-Space' select-pane -t:.+



      # run '~/.config/tmux/plugins/tpm/tpm'
    '';
    */

    keyMode = "vi";
    mouse = true;

    plugins = with pkgs; [
      tmuxPlugins.yank
      tmuxPlugins.dracula
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.tmux-fzf
    ];
  };
}

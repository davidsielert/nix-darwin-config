{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
  };

  home.shellAliases = {
    k = "kubectl";

    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };
  programs.tmux = {
    enable = true;
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

      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'

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

      plugins = with pkgs; [
        tmuxPlugins.yank
        tmuxPlugins.sensible
        tmuxPlugins.catppuccin

      ];
  };
}

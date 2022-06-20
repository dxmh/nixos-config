{ config, pkgs, ... }: {

home-manager.users.dom = { pkgs, ... }: {

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.sessionVariables = {
    BROWSER = "${pkgs.surf}/bin/surf";
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  };

  home.packages = with pkgs; [
    gnumake
    gh
    z-lua
    shellcheck
    unzip
    qrencode
    awscli2
    terraform
    jq
    jless
    ripgrep
    # graphical
    dwm
    dmenu
    slstatus
    surf
    electrum
    xclip
  ];

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./config/kitty.conf;
  };

  # Snazzy theme for Kitty terminal
  xdg.configFile."kitty/snazzy.conf".text = builtins.readFile (
    builtins.fetchurl {
      url = "https://raw.githubusercontent.com/connorholyday/kitty-snazzy/6ae245a6319dc0d6416457355678fa48f275c971/snazzy.conf";
      sha256 = "cc43a48764eed43b4afe86250bc12740c8872064536cda59f6be56f5da684319";
    }
  );

  programs.bat = {
    enable = true;
    config = {
      theme = "Sublime Snazzy";
    };
  };

  programs.git = {
    enable = true;
    userName = "Dom H";
    userEmail = "dom@hxy.io";
    delta = {
      enable = true;
      options = {
        side-by-side = true;
        syntax-theme = "Sublime Snazzy";
      };
    };
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      a = "aws";
      d = "docker";
      dc = "docker-compose";
      e = "vim";
      g = "git";
      gc = "git commit -v";
      gco = "git checkout";
      gcp = "git commit -v -p";
      gd = "git diff";
      gl = "git log";
      gs = "git status";
      gst = "git stash";
      "g." = "git switch -";
      push = "git push";
      pull = "git pull";
      m = "make -s";
      nrs = "sudo nixos-rebuild -I nixos-config=/home/dom/code/hxy/nixos-config/configuration.nix switch";
      ne = "vim ~/code/hxy/nixos-config/configuration.nix";
      ns = "nix-shell";
      psg = "ps auxwww | grep -i";
      v = "vagrant";
      xp = "xrandr --output Virtual-1 --preferred";
      t = "z"; # z is not pinky-friendly; t is for "to"
      tf = "terraform";
      start = "sudo systemctl start";
      stop = "sudo systemctl stop";
      status = "sudo systemctl status";
      reboot = "sudo systemctl reboot";
      reload = "sudo systemctl reload";
      restart = "sudo systemctl restart";
      qr = "qrencode -t ansi";
      "-" = "cd -";
      "." = "cd -";
      ".." = "cd ../";
      "..." = "cd ../../";
      pw = "tr -dc [:alnum:] < /dev/urandom | head -c30";
    };
    shellInit = ''
      # Disable welcome message
      set fish_greeting
      # Enable z (https://github.com/skywind3000/z.lua)
      ${pkgs.z-lua}/bin/z --init fish | source
      set -gx _ZL_CD cd
      # Enable AWS CLI autocompletion: github.com/aws/aws-cli/issues/1079
      complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
    '';
    interactiveShellInit = ''
      # Colorscheme: "Tomorrow Night Bright" (from `fish_config`)
      set -U fish_color_normal normal
      set -U fish_color_command c397d8
      set -U fish_color_quote b9ca4a
      set -U fish_color_redirection 70c0b1
      set -U fish_color_end c397d8
      set -U fish_color_error d54e53
      set -U fish_color_param 7aa6da
      set -U fish_color_comment e7c547
      set -U fish_color_match --background=brblue
      set -U fish_color_selection white --bold --background=brblack
      set -U fish_color_search_match bryellow --background=brblack
      set -U fish_color_history_current --bold
      set -U fish_color_operator 00a6b2
      set -U fish_color_escape 00a6b2
      set -U fish_color_cwd green
      set -U fish_color_cwd_root red
      set -U fish_color_valid_path --underline
      set -U fish_color_autosuggestion 969896
      set -U fish_color_user brgreen
      set -U fish_color_host normal
      set -U fish_color_cancel -r
      set -U fish_pager_color_completion normal
      set -U fish_pager_color_description B3A06D yellow
      set -U fish_pager_color_prefix normal --bold --underline
      set -U fish_pager_color_progress brwhite --background=cyan
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;
      git_status.disabled = false;
      line_break.disabled = false;
      python.symbol = " ";
      right_format = "$time";
      status.disabled = false;
      username.disabled = true;
      vagrant.disabled = true;
      aws.disabled = true;
      php.disabled = true;
      nodejs.disabled = true;
      time = {
        disabled = false;
        time_format = "%T";
        format = "[$time]($style)";
        style = "bright-black";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      editorconfig-vim
      fzf-vim
      fzfWrapper
      starsearch-vim
      vim-commentary
      vim-eunuch
      vim-fugitive
      vim-nix
      vim-oscyank
      vim-repeat
      vim-rhubarb
      vim-rsi
      vim-sensible
      vim-snazzy
      vim-speeddating
      vim-surround
      vim-terraform
      vim-unimpaired
      vim-vinegar
    ];
    extraConfig = builtins.readFile ./config/vimrc;
  };

  programs.tmux = {
    enable = true;
    newSession = true; # spawn a session if trying to attach and none are running
    extraConfig = builtins.readFile ./config/tmux.conf;
  };

  xsession = {

    enable = true;
    initExtra = ''
      slstatus &
      kitty &
    '';

  };

  # Scalable cursor theme to fix tiny pointer on HiDPI display.
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
  };


};

}

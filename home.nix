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
    # graphical
    dwm
    dmenu
    slstatus
    surf
    electrum
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
      d = "docker";
      dc = "docker-compose";
      e = "vim";
      g = "git";
      gc = "git commit -v";
      gcp = "git commit -v -p";
      gd = "git diff";
      gl = "git log";
      gs = "git status";
      m = "make -s";
      nrs = "sudo nixos-rebuild -I nixos-config=/home/dom/code/hxy/nixos-config/configuration.nix switch";
      ne = "vim ~/code/hxy/nixos-config/configuration.nix";
      ns = "nix-shell";
      v = "vagrant";
      xp = "xrandr --output Virtual-1 --preferred";
      start = "sudo systemctl start";
      stop = "sudo systemctl stop";
      reboot = "sudo systemctl reboot";
      reload = "sudo systemctl reload";
      restart = "sudo systemctl restart";
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      git_status.disabled = true;
      line_break.disabled = true;
      python.symbol = " ";
      right_format = "$time";
      status.disabled = false;
      username.disabled = true;
      vagrant.disabled = true;
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

    # Scalable cursor theme to fix tiny pointer on HiDPI display.
    pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 128;
    };

  };

};

}

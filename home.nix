{ config, pkgs, ... }: {

home-manager.users.dom = { pkgs, ... }: {

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    fishPlugins.pure
    gnumake
    gh
    # graphical
    dwm
    dmenu
    slstatus
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
    delta.enable = true;
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

    # Scalable cursor theme to fix tiny pointer on HiDPI display.
    pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 128;
    };

  };

};

}

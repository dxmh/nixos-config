{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  time.timeZone = "Europe/London";

  networking.useDHCP = false;
  networking.interfaces.enp0s5.useDHCP = true;

  # Enable docker. Start on demand by socket activation rather than on boot.
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  # Enable the fish shell system-wide. This provides vendor fish completions, etc.
  programs.fish.enable = true;

  # Define a user account.
  users.users.dom = {
    isNormalUser = true;
    initialPassword = "hunter2";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpIMrPStsNADURgP6ZXp+1PwMrIMOthUwVLWdP11XBd"
    ];
  };

  # Automatically log in after boot.
  services.getty.autologinUser = "dom";

  # Configure user account with home-manager.
  home-manager.users.dom = { pkgs, ... }: {

    home.packages = with pkgs; [
      fishPlugins.pure
      gnumake
      gh
      # graphical
      electrum
    ];

    xsession.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 128;
    };

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

    programs.i3status = {
      enable = true;
      general = {
        interval = 1;
      };
      modules = {
        ipv6.enable = false;
        "wireless _first_".enable = false;
        "battery all".enable = false;
      };
    };

    programs.tmux = {
      enable = true;
      newSession = true; # spawn a session if trying to attach and none are running
      extraConfig = builtins.readFile ./config/tmux.conf;
    };

  };

  # System-wide packages.
  environment.systemPackages = with pkgs; [
    bat
    bind # for dig
    curl
    htop
    tree
    vim
  ];

  # System-wide environment variables.
  environment.variables = {
    EDITOR = "vim";
  };

  # Setup windowing environment
  services.xserver = {
    enable = true;

    layout = "us";
    dpi = 220;

    displayManager = {
      defaultSession = "none+i3";
      autoLogin = {
        enable = true;
        user = "dom";
      };
      # Set resolution to full-screen 15" MBP until automatic adjustment is working
      # https://askubuntu.com/a/377944
      sessionCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --newmode "3456x2160_60.00"  642.00  3456 3744 4120 4784  2160 2163 2169 2237 -hsync +vsync
        ${pkgs.xorg.xrandr}/bin/xrandr --addmode Virtual-1 "3456x2160_60.00"
        ${pkgs.xorg.xrandr}/bin/xrandr --size '3456x2160_60.00'
      '';
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        arandr
      ];
    };

  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  # Convenience...
  security.sudo.wheelNeedsPassword = false;

}

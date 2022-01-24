{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./home.nix
      <home-manager/nixos>
    ];

  nixpkgs.overlays = [
    (final: prev: {
      sf-mono-liga-bin = pkgs.callPackage ./sfmono.nix {};
      dwm = prev.dwm.overrideAttrs (oldAttrs: rec {
        patches = [
          (prev.fetchpatch {
            url = "https://dwm.suckless.org/patches/bar_height/dwm-bar-height-6.2.diff";
            sha256 = "0x70ca7a5cwp5ny888g4vhga4gl3qba3w7nawh954cjlx234q1rz";
          })
          (prev.fetchpatch {
            url = "https://dwm.suckless.org/patches/smartborders/dwm-smartborders-6.2.diff";
            sha256 = "0chx3i2ddnx1i2c2hfp2m693khjfmfx2fmvwp6qa79jqymmlzdxs";
          })
        ];
        configFile = prev.writeText "config.h" (builtins.readFile ./config/dwm-config.h);
        postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
      });
      slstatus = prev.slstatus.overrideAttrs (oldAttrs: rec {
        configFile = prev.writeText "config.h" (builtins.readFile ./config/slstatus-config.h);
        postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
      });
      vimPlugins = prev.vimPlugins // prev.callPackage ./vim-plugins.nix {};
    })
  ];

  nix = {
    # Automatic optimisation of duplicate files:
    autoOptimiseStore = true;
    # Automatic garbage collection:
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Perform automatic garbage collection when /nix/store/ drops below 100MB
    # free space, keep going until 1GB of free space is available (or there is
    # no more garbage):
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

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

  # System-wide packages.
  environment.systemPackages = with pkgs; [
    bat
    bind # for dig
    curl
    htop
    killall
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
    windowManager.dwm.enable = true;
    displayManager = {
      autoLogin = {
        enable = true;
        user = "dom";
      };
      defaultSession = "none+dwm";
    };
  };

  fonts.fonts = with pkgs; [
    sf-mono-liga-bin
  ];

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

  # Use system-level pkgs and profiles. These may become the default values in future.
  # https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

}

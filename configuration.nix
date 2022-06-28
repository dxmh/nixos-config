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
            url = "https://dwm.suckless.org/patches/bar_height/dwm-bar-height-spacing-6.3.diff";
            sha256 = "1z6f3l9myv3xj11jyx0s6xzb69b8jmsvji2jyvhnvywxhdb7l89w";
          })
          # (prev.fetchpatch {
          #   url = "https://dwm.suckless.org/patches/smartborders/dwm-smartborders-6.2.diff";
          #   sha256 = "0chx3i2ddnx1i2c2hfp2m693khjfmfx2fmvwp6qa79jqymmlzdxs";
          # })
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
    # Flakes are only available in nix unstable
    package = pkgs.nixUnstable;
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
      experimental-features = nix-command flakes
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
    comma # run packages without installing them
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

  # Internal CA
  security.pki.certificates = [
    ''
    -----BEGIN CERTIFICATE-----
    MIIDyzCCArOgAwIBAgIUIWqHTPZYcDNRcT80iBmrxfLwSeUwDQYJKoZIhvcNAQEL
    BQAwdTELMAkGA1UEBhMCVUsxGDAWBgNVBAgMD0dsb3VjZXN0ZXJzaGlyZTEPMA0G
    A1UEBwwGU3Ryb3VkMQ8wDQYDVQQKDAZoeHkuaW8xDzANBgNVBAMMBmh4eS5pbzEZ
    MBcGCSqGSIb3DQEJARYKZG9tQGh4eS5pbzAeFw0yMjAyMDIxMDAwMTdaFw0yNzAy
    MDExMDAwMTdaMHUxCzAJBgNVBAYTAlVLMRgwFgYDVQQIDA9HbG91Y2VzdGVyc2hp
    cmUxDzANBgNVBAcMBlN0cm91ZDEPMA0GA1UECgwGaHh5LmlvMQ8wDQYDVQQDDAZo
    eHkuaW8xGTAXBgkqhkiG9w0BCQEWCmRvbUBoeHkuaW8wggEiMA0GCSqGSIb3DQEB
    AQUAA4IBDwAwggEKAoIBAQDqLpnBv1soYuDr5bVGA6Lrzou2MRQLDtbItY1XtAWu
    /u2xyjTDv3uRlB1bjj2AdRRQ/h5p/I1CZeaApFp50h5v16W7l17+kGKWuAg0h43X
    0/CQDzcBbXvI0I/Z+DufHUq3Ujk1k9LS/GtWEo2yP2BbeBnpyxLuyxMwf9nJY2s+
    m10F7mDljvNHQ5MftKGmqot0cTcR+c9d2FvAadZvxzO/C6xoSpmuW9F8p1iuOYj3
    /OixRYYHLkL5PsJdaq/OzM6NSaaKy7gQ6V45bbUfPBz+dvpaw0Wr6uqAMvMvcCW5
    VCNnCMdd8bl15k6UoSQuMzn8IpzvGlVe+e71RUfOz/FVAgMBAAGjUzBRMB0GA1Ud
    DgQWBBQaDVIdsR2bB++FEkEQYvJzxygU1DAfBgNVHSMEGDAWgBQaDVIdsR2bB++F
    EkEQYvJzxygU1DAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQCa
    CVyFpxGH33UTuNOJtHYyi26hTqt7Sega8xOAEzbjcfh8bL73L24/ePAUh316cUP8
    D0r6/o91A0S2iu2lLHnKxHwRPdTn9jvO83Cy6AOkCutWs+keL2+poYSZS8YeekHj
    jMNdzGoSJFKOPwKCaG5t3msW/J7zTEooZY7n31Xqj+KwGi93Zm4YYlzooSpLUaPC
    DnmhyYSPdF++QKKdDDPyaDOV/v5h0yt+LL6mbF0qzLm+x0F7LYb7xmTdzxQLqqXP
    vjxfn3rYq3p5YTZL5m2kTi9SpQuIGL5braUb7U0praAaYslzF8la8sgCSIqyQ9P+
    UX4dpwjqVvDSGJ4BVQ5h
    -----END CERTIFICATE-----
    ''
  ];

}

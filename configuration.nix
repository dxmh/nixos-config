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
    })
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
    displayManager.startx.enable = true;
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

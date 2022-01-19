# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s5.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = false;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable docker. Start on demand by socket activation rather than on boot.
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  # Enable the fish shell system-wide.
  # This provides vendor fish completions, etc.
  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
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

  # Configure user account with home-manager.
  home-manager.users.dom = { pkgs, ... }: {
    home.packages = with pkgs; [
      fishPlugins.pure
      gnumake
      gh
    ];
    xsession.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 128;
    };
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
        nrs = "sudo nixos-rebuild switch";
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
      extraConfig = ''
        " Put leader key under the thumb
        nnoremap <Space> <NOP>
        let mapleader = "\<Space>"

        " General configuration
        set path+=** " recursively add contents of current directory to path
        set list " show invisible characters such as tabs and trailing spaces
        set number relativenumber " show relative line numbers except for current line
        set ignorecase smartcase " ignore case unless search patterns contains capitals
        set showcmd " show commands as they're being typed
        set hidden " allow switching buffers without saving
        set hlsearch " search highlighting on

        " Easier access to frequent commands
        nnoremap <leader><leader> :Buffers<Return>
        nnoremap <leader>bd :bd<CR>
        nnoremap <leader>g :Git<CR>
        nnoremap <leader>q :q<CR>
        nnoremap <leader>s :w<CR>
        nnoremap <leader>w :w<CR>
        nnoremap <leader>x :x<CR>
        nnoremap <leader>f :Files<Return>
        nnoremap <leader>r :Rename <c-r>=expand('%')<CR>

        " Line wrapping
        set wrap " enable soft-wrapping
        set linebreak " don't soft-wrap mid-word
        set breakindent " continue indentation of soft-wrapped line
        set showbreak=\\\  " prefix soft-wrapped lines with a backslash
        set textwidth=80 " column to hard-wrap at (with gq for example)
        set formatoptions-=tc " don't automatically hard-wrap text or comments

        " Use tabs for indentation and spaces for alignment.
        " This ensures everything will line up independent of tab size.
        " - https://suckless.org/coding_style
        " - https://vim.fandom.com/wiki/VimTip1626
        set noexpandtab copyindent preserveindent softtabstop=0 shiftwidth=2 tabstop=2

        " Spellchecking
        " Vim offers suggestions! See `:help z=` and `:help i^xs`...
        set nospell " off by default
        set spelllang=en_gb
        nnoremap <leader>rs 1z=
      '';
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
      extraConfig = ''
        # General settings
        set -g history-limit 99999 # set big history limit
        set -g mode-keys vi # use vim keybindings in copy mode
        set -g escape-time 0 # disable delay for escape key press
        set -g default-terminal "xterm-256color" # hack $TERM so VIM can do ctrl+arrows
        set -g renumber-windows on # automatically renumber window IDs when one closes
        set -g base-index 1 # start numbering windows from 1 (rather than 0)

        # Reload config
        bind r source-file ~/.tmux.conf \; \
          display-message "tmux config reloaded..."

        # Name windows manually
        setw -g automatic-rename off

        # Open windows in $HOME and panes in current working directory
        bind -n M-N new-window -c "$HOME"
        bind 'c' new-window -c "$HOME"
        bind '%' split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"

        # Pane styles
        set -g pane-border-status off
        set -g pane-border-style "fg=colour08"
        set -g pane-active-border-style "fg=colour4"
        set -g display-panes-colour "colour08"
        set -g display-panes-active-colour "colour04"

        # Window list
        set -g status-style "fg=colour08, bg=default"
        setw -g window-status-style "fg=default"
        setw -g window-status-current-style "fg=colour04"
        setw -g window-status-separator "  "
        setw -g window-status-format '#I:#W'
        setw -g window-status-current-format "#I:#W#[fg=red]#(printf '%%s\n' '#F' | tr -d '*')"

        # Status bar
        setw -g status-justify left
        set -g status-left ""
        set -g status-right '#( whoami )@#( hostname ) #{pane_current_command} #( date +%H:%M )'
        set -g status-interval 1

        # Pane selection
        bind-key -n M-Up select-pane -t :.+ -Z
        bind-key -n M-k select-pane -t :.+ -Z
        bind-key -n M-Down select-pane -t :.- -Z
        bind-key -n M-j select-pane -t :.- -Z

        # Window selection
        bind-key -n M-1 select-window -t 1
        bind-key -n M-2 select-window -t 2
        bind-key -n M-3 select-window -t 3
        bind-key -n M-4 select-window -t 4
        bind-key -n M-5 select-window -t 5
        bind-key -n M-6 select-window -t 6
        bind-key -n M-7 select-window -t 7
        bind-key -n M-8 select-window -t 8
        bind-key -n M-9 select-window -t 9

        # Similar copy/paste bindings to VIM
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi r send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      '';
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bat
    curl
    htop
    vim
    bind # for dig
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
        kitty
        arandr
      ];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  # Convenience
  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "dom";

}


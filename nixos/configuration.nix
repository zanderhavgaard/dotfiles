# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # install latest kernel
  # https://nixos.org/manual/nixos/stable/#sec-kernel-config
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "vostok"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable thunderbolt daemon
  services.hardware.bolt.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zander = {
    isNormalUser = true;
    description = "Zander Havgaard";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      #  thunderbird
    ];
  };
  # setup home-manager for user
  home-manager.users.zander =
    { pkgs, ... }:
    {
      home.packages = [ ];
      #programs.zsh = {
      #enable = true;
      #zplug = {
      # enable = true;
      #};
      #};

      # The state version is required and should stay at the version you originally installed.
      home.stateVersion = "24.05";
    };

  # Install firefox.
  programs.firefox.enable = true;

  # Install shells
  programs.zsh.enable = true;

  # Install docker and start daemon
  virtualisation.docker.enable = true;

  # Allow unfree packages
  #nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;
  # https://nix.dev/guides/faq#how-to-run-non-nix-executables
  #programs.nix-ld.libraries = with pkgs; [
  # Add any missing dynamic libraries for unpackaged programs
  # here, NOT in environment.systemPackages
  #];

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      # requires adding the unstable channel manually:
      # sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable
      # sudo nix-channel --update
      unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    neovim
    zellij
    starship
    zplug
    wget
    curl
    htop
    btop
    eza
    fd
    ripgrep
    sad
    fzf
    bat
    delta
    fastfetch
    pfetch-rs
    git
    gh
    hub
    wezterm
    alacritty
    nerdfonts
    chromium
    slack
    thunderbird
    usbutils
    unzip

    prettyping
    ncdu
    tealdeer
    silver-searcher
    jq
    figlet
    lolcat
    cowsay
    tokei
    gum
    yazi
    unstable.zed-editor

    discord
    feh
    xfce.thunar
    zathura
    mpv
    yt-dlp
    guvcview
    lazygit
    kustomize
    kubeseal
    shellcheck
    yamllint
    shfmt
    nodePackages_latest.nodejs
    nodePackages_latest.prettier
    eksctl
    magic-wormhole
    spotify
    ly
    glow
    kind
    hadolint
    lazydocker
    yq-go
    go-task
    gnumake
    libxml2

    nixfmt-rfc-style

    pkgs.gnome3.gnome-tweaks

    bitwarden-desktop
    bitwarden-cli
    _1password-gui
    _1password

    jetbrains-toolbox
    jetbrains.pycharm-professional

    python3
    python3Packages.pip
    poetry
    # unstable.pyenv

    # needed for pyenv, see: https://semyonsinchenko.github.io/ssinchenko/post/using-pyenv-with-nixos/
    # gcc
    # gnumake
    # zlib
    # libffi
    # readline
    # bzip2
    # openssl
    # ncurses

    rustup
    go
    gcc

    awscli2
    kubernetes-helm
    kubectl
    kubectx
    k9s

    tenv
  ];

  # setup build flags for
  environment.sessionVariables = {
    PYENV_ROOT = "$HOME/.pyenv";
    # pyenv flags to be able to install Python
    CPPFLAGS = "-I${pkgs.zlib.dev}/include -I${pkgs.libffi.dev}/include -I${pkgs.readline.dev}/include -I${pkgs.bzip2.dev}/include -I${pkgs.openssl.dev}/include";
    CXXFLAGS = "-I${pkgs.zlib.dev}/include -I${pkgs.libffi.dev}/include -I${pkgs.readline.dev}/include -I${pkgs.bzip2.dev}/include -I${pkgs.openssl.dev}/include";
    CFLAGS = "-I${pkgs.openssl.dev}/include";
    LDFLAGS = "-L${pkgs.zlib.out}/lib -L${pkgs.libffi.out}/lib -L${pkgs.readline.out}/lib -L${pkgs.bzip2.out}/lib -L${pkgs.openssl.out}/lib";
    CONFIGURE_OPTS = "-with-openssl=${pkgs.openssl.dev}";
    PYENV_VIRTUALENV_DISABLE_PROMPT = "1";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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
  system.stateVersion = "24.05"; # Did you read the comment?

}

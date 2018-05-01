{ config, pkgs, ... }:
let intero-neovim = pkgs.vimUtils.buildVimPlugin {
    name = "intero-neovim";
    src = pkgs.fetchFromGitHub {
      owner = "parsonsmatt";
      repo = "intero-neovim";
      rev = "26d340ab0d6e8d40cbafaf72dac0588ae901c117";
      sha256 = "0y4bbbj6v9jq825ffpdx03hi6ldszqh2zxasc6h1b0vkpjmdc8y3";
    };
  };
in {
  imports =
    [
      ./hardware-configuration.nix
    ];

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "colemak/en-latin9";
    defaultLocale = "en_AU.UTF-8";
  };

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "carbon";
    wireless.enable = true;
    firewall = { 
      allowedTCPPorts = [  22  ];
    };
  };
  time.timeZone = "Australia/Sydney";

  environment = {
    systemPackages = with pkgs; [
    i3 i3lock compton
    git
    neovim google-chrome
    screen
    binutils
    rxvt_unicode
    acpi
    hackrf
    stack
    ghc
    stdenv
    ];
    shellAliases = { vim = "nvim"; };
  };

  programs.vim.defaultEditor = true;
  programs.ssh.startAgent = true;

  fonts = {
    fonts = with pkgs; [
      corefonts
      ubuntu_font_family
      terminus_font
      terminus_font_ttf
      freetype_subpixel
    ];
  };

  programs.zsh.enable = true;
  virtualization.libvirt.enable = true;

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  boot = {
    kernelParams = [ "acpi.ec_no_wakeup=1 psmouse.synaptics_intertouch=1" ];
    kernelModules = ["i2c_i801" "elan_i2c" "rmi_smbus"  "kvm_intel"];
    
    
    loader.grub = {
      enable = true;
      version = 2;
      device = "nodev";
      gfxmodeEfi = "2560x1440";
    };


    loader.systemd-boot.enable = true;

    loader.efi.canTouchEfiVariables = true;

    initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/a56d840c-e56c-4d58-b788-471c54b35ed0";
      preLVM = true;
      allowDiscards = true;
    }
    ];
  };

  services.offlineimap = {
    enable = true;
    install = true;
   };
  services.xserver = {
  	autorun = true;
	displayManager.slim = {
	  defaultUser = "christian";

	};

	synaptics.enable = true;
	windowManager.i3.enable = true;
	windowManager.default = "i3";
	enable = true;
	layout = "us";
	xkbVariant = "colemak";
  };

  services.sshd.enable = true;

  # services.ntp.enable = true;

  hardware.trackpoint = {
  	enable = true;
	sensitivity = 255;
	speed = 200;
	emulateWheel = true;
  };

  
  # powerManagement.cpuFreqGovernor = "ondemand";
  powerManagement.enable = true;
  services.tlp.enable = true;

  services.redshift = {
  	enable = true;
	provider = "geoclue2";
  };

  hardware.enableAllFirmware = true;
  services.fprintd.enable = true;
        nixpkgs.config.packageOverrides = pkgs: {
        freetype_subpixel = pkgs.freetype.override {
          useEncumberedCode = true;
        };
        neovim = pkgs.neovim.override {
          configure = {
          packages.neovim2 = with pkgs.vimPlugins; {

          start = [ intero-neovim neomake ctrlp];
          opt = [ ];
        };      
      };

      };
    };
}

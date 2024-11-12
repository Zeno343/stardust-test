{ pkgs, ... }:
{
  system.stateVersion = "24.05";
  time.timeZone = "America/New_York";
  imports = [ ./hardware-configuration.nix ];

  home-manager.users.zeno = import ./home.nix;
  users.users.zeno = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "audio"
      "video"
      "wheel"
    ];
  };

  environment.systemPackages = with pkgs; [
    brave
    obsidian
    bluez
  ];

  programs = {
    fish.enable = true;
  };

  networking = {
    hostName = "codex";
    networkmanager.enable = true;
  };

  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    xserver = {
      enable = true;
      windowManager.i3.enable = true;
    };
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware = {
    graphics.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}

{
  inputs,
  lib,
  config,
  ...
}:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.networkmanager.enable = true;

      # Set your time zone.
      time.timeZone = "Asia/Taipei";
      i18n.defaultLocale = "en_US.UTF-8";
      users.users.hugo = {
        isNormalUser = true;
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
        packages = with pkgs; [
        ];
      };

      # programs.firefox.enable = true;

      # List packages installed in system profile.
      # You can use https://search.nixos.org/ to find more packages (and options).
      environment.systemPackages = with pkgs; [
        helix
        git
        gh
      ];

      # Enable the OpenSSH daemon.
      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
      };

      system.stateVersion = "25.11";

    };
}

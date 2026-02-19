{
  flake.modules.nixos.base =
    { pkgs, config, ... }:
    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

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

      systemd.user.services = {
        # Reboot at 5am every day
        auto-reboot = {
          description = "Auto Reboot Service";
          startAt = [ "Mon 05:00:00" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "/run/current-system/sw/bin/reboot";
          };
        };
      };

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 3d";
      };

      system.stateVersion = "25.11";

    };
}

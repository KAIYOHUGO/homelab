{
  flake.modules.nixos.rasp4 =
    {
      lib,
      config,
      ...
    }:
    {
      # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      boot.loader.grub.enable = false;
      # Enables the generation of /boot/extlinux/extlinux.conf
      boot.loader.generic-extlinux-compatible.enable = true;

      boot.initrd.availableKernelModules = [ "xhci_pci" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
        fsType = "ext4";
      };

      swapDevices = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    };
}

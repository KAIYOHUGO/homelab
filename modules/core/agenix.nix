{ inputs, self, ... }:
{
  flake.agenix-rekey = inputs.agenix-rekey.configure {
    userFlake = self;
    nixosConfigurations = self.nixosConfigurations;
  };

  perSystem =
    {
      config,
      pkgs,
      inputs',
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [ inputs'.agenix-rekey.packages.default ];
      };
    };
  flake.modules.nixos.base =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
      ];

      age.rekey = {
        storageMode = "local";
        masterIdentities = [ "/home/hugo/.ssh/id_ed25519_agenix" ];
        localStorageDir = ../../.secrets/${config.networking.hostName};
      };
    };
  flake.modules.nixos.mininas =
    { config, ... }:
    {
      age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPGJXex0XbUgq6mp1TXlsvLR1EXlYERyRdwoezn7EcRT";
    };
  flake.modules.nixos.rasp4=
    { config, ... }:
    {
      age.rekey.hostPubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfP8YyYsWg/ilA57CwXWO6WMmLA/V2At+VlhBJXLsczd9xQYFUkFuSRPuMz3COZ7hE/onhSli/Cu0Hgx0oc4/wfZ+bEyEaxTHwof3j3Y3Bd0rq2f2RS2dcXOWcQNZlSJU7VAj71QdKg+WOxt0bgmmS8cqwqJxlEAr0k/PwPRPhMeqxM8wmD0iE1Bu6jHzpRcmADWnNrJYPHzzvUm+/SKYcCcL66HrKIM8jER6Tm8ihkielLCOyJIKN6KK873ZuTLMIbCvCjbgKwAOM7+/UoOXMCXuyESUQiVMAxfxy/j9HYM88kLgeZssXAAqisSHETN5EhInv057jUF2imi+RbJ8G/TxRbu8Wk4Y7vpVcN8jlPETd+31spoFmvZzGnIMHKdUnjuKB70anQgV4VG3cW10DZV6NXSaOTNuURqU8yCO9MDf2QQ/ZJNtTC9W0zQH0cWGVe4MFjEhRhP0XteIORqQ45uGSLZeDoIUqCVgkBvFp5mBVykzFynmpHpH/KHvVoOfg0v1DoAu0tlULeYzB9o4PAmeOQW1HeIhdzAzgMb7uxM+ojvb9ELdkuMKfbbbovrvz+lbJyKhMTYGaNQiRgIWZVPEx2lBggi4caJ8PjfgCOzh2+enB2P13uPUwtB2d2BT5W5nalN96C+lKhSlXq6FObuikMJaBXSTUd6YZCo72IQ==";
    };
}

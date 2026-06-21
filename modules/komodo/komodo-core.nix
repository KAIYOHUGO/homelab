{
  flake.modules.nixos.mininas =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    {
      age.secrets."komodo-mininas-core.env".rekeyFile = ./mininas-core.env.age;
      age.secrets."komodo-core.key".rekeyFile = ./core.key.age;

      systemd.tmpfiles.settings."10-komodo-core" = {
        "/var/lib/komodo/".d = {
          mode = "0700";
          user = "root";
          group = "root";
        };
        "/var/lib/komodo/backup".d = {
          mode = "0700";
          user = "root";
          group = "root";
        };
      };
   };
}

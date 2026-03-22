{
  flake.modules.nixos.rasp4 =
    { config, lib, ... }:
    {
      homelab.mappings.blocky = "rasp4";
    };
}

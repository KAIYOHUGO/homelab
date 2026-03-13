{
  flake.modules.nixos.rasp4 =
    { config, ... }:
    {
      age.secrets."lldap-jwt".rekeyFile = ./lldap-jwt.age;
      age.secrets."lldap-key".rekeyFile = ./lldap-key.age;
      age.secrets."lldap-pass".rekeyFile = ./lldap-pass.age;

      networking.firewall = {
        allowedTCPPorts = [
          3230
          3231
        ];
      };

      services.lldap = {
        enable = true;

        settings = {
          ldap_port = 3230;
          http_port = 3231;
          ldap_base_dn = "dc=homelab, dc=lan";
          force_ldap_user_pass_reset = "always";
        };

        environment = {
          LLDAP_JWT_SECRET_FILE = "%d/lldap-jwt";
          LLDAP_KEY_SEED_FILE = "%d/lldap-key";
          LLDAP_LDAP_USER_PASS_FILE = "%d/lldap-pass";
        };
      };
      systemd.services.lldap.serviceConfig.LoadCredential = [
        "lldap-jwt:${config.age.secrets."lldap-jwt".path}"
        "lldap-key:${config.age.secrets."lldap-key".path}"
        "lldap-pass:${config.age.secrets."lldap-pass".path}"
      ];
    };
}

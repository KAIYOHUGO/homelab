top: {
  homelab.mappings.lldap = "rasp4";

  flake.modules.nixos.rasp4 =
    { config, ... }:
    {
      age.secrets."lldap-jwt".rekeyFile = ./lldap-jwt.age;
      age.secrets."lldap-key".rekeyFile = ./lldap-key.age;
      age.secrets."lldap-pass".rekeyFile = ./lldap-pass.age;

      services.lldap = {
        enable = true;

        settings = {
          ldap_port = 3230;
          http_port = 3231;
          ldap_base_dn = "dc=k9h, dc=uk";
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

      services.traefik.dynamicConfigOptions.http = {
        routers.lldap_http = {
          rule = "Host(`lldap.${top.config.homelab.lan-domain}`)";
          service = "lldap_http";
          entrypoints = [
            "web"
            "websecure"
          ];
          middlewares = [
            "lan-only"
          ];
        };
        services.lldap_http = {
          loadbalancer.servers = [
            {
              url = "http://localhost:${toString config.services.lldap.settings.http_port}";
            }
          ];
        };
      };
    };
}

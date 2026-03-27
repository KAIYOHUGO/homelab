top: {
  # bypass cloudflare
  homelab.overrides.auth = "rasp4";

  flake.modules.nixos.rasp4 =
    { config, ... }:
    let
      mkAge = file: {
        rekeyFile = file;
        owner = config.services.authelia.instances.homelab.user;
        group = config.services.authelia.instances.homelab.group;
      };
    in
    {
      age.secrets."auth-lldap-pass" = mkAge ./auth-lldap-pass.age;
      age.secrets."auth-jwt" = mkAge ./auth-jwt.age;
      age.secrets."auth-enc" = mkAge ./auth-encryption.age;
      services.authelia.instances.homelab = {
        enable = true;
        environmentVariables = {
          AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.age.secrets."auth-lldap-pass".path;
        };

        settings = {
          theme = "auto";
          # ❗ need to be `/avr/lib/authelia-{name}`
          storage.local.path = "/var/lib/authelia-homelab/db.sqlite3";
          authentication_backend.ldap = {
            implementation = "lldap";
            address = "ldap://localhost:${toString config.services.lldap.settings.ldap_port}";
            base_dn = "dc=k9h, dc=uk";
            user = "uid=authelia, ou=people, dc=k9h, dc=uk";

            # the default
            # users_filter = "(&(|({username_attribute}={input})({mail_attribute}={input}))(objectClass=person))";
            # groups_filter = "(&(member={dn})(objectClass=groupOfNames))";

            attributes = {
              display_name = "cn";
              group_name = "cn";
              mail = "mail";
              username = "uid";
            };
          };

          session = {
            # The period of time the user can be inactive for until the session is destroyed.
            # Useful if you want long session timers but don’t want unused devices to be vulnerable.
            inactivity = "1M";
            # The period of time before the cookie expires and the session is destroyed.
            # This is overridden by remember_me when the remember me box is checked.
            expiration = "2M";
            # The period of time before the cookie expires and the session is destroyed when the remember me box is checked.
            # Setting this to -1 disables this feature entirely for this session cookie domain.
            remember_me = "1y";
            cookies = [
              {
                domain = top.config.homelab.domain;
                authelia_url = "https://auth.${top.config.homelab.domain}";
              }
            ];
          };

          access_control = {
            rules = top.config.homelab.auths ++ [
              {
                domain = "*.${top.config.homelab.domain}";
                policy = "one_factor";
              }
            ];
          };

          server.endpoints.authz.forward-auth.implementation = "ForwardAuth";
          notifier.filesystem.filename = "/var/lib/authelia-homelab/notification.txt";
        };
        secrets = {
          jwtSecretFile = config.age.secrets."auth-jwt".path;
          storageEncryptionKeyFile = config.age.secrets."auth-enc".path;
        };
      };

      services.traefik.dynamicConfigOptions.http = {
        routers.authelia = {
          rule = "Host(`auth.${top.config.homelab.domain}`)";
          service = "authelia";
          entrypoints = [
            "web"
            "websecure"
          ];
        };
        services.authelia = {
          loadbalancer.servers = [
            # the default port
            {
              url = "http://localhost:9091";
            }
          ];
        };
      };
    };
  flake.modules.nixos.base =
    {
      config,
      ...
    }:
    {
      services.traefik.dynamicConfigOptions.http = {
        middlewares.auth = {
          forwardAuth = {
            address = "https://auth.${top.config.homelab.domain}/api/authz/forward-auth";
            authResponseHeaders = [
              "Remote-User"
              "Remote-Groups"
              "Remote-Email"
              "Remote-Name"
            ];
          };
        };
      };
    };
}

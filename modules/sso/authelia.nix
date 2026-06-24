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
      age.secrets."auth-session" = mkAge ./auth-session.age;
      age.secrets."auth-oidc-hmac" = mkAge ./auth-oidc-hmac.age;
      age.secrets."auth-oidc-jwk-key" = mkAge ./auth-oidc-jwk-key.age;
      services.authelia.instances.homelab = {
        enable = true;
        environmentVariables = {
          AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.age.secrets."auth-lldap-pass".path;
        };

        settings = {
          log.level = "warn";
          theme = "auto";
          # ❗ need to be `/var/lib/authelia-{name}`
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

            redis = {
              host = "localhost";
              port = config.services.redis.servers.authelia.port;
            };
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
          identity_providers = {
            oidc = {
              jwks = [
                {
                  # The default value
                  algorithm = "RS256";
                  use = "sig";
                }
              ];
              clients = [
                {
                  client_id = "immich";
                  client_name = "immich";
                  client_secret = "$pbkdf2-sha512$310000$Ko97HSYUOkq.ws0DldhQiA$HWamZ7EziyvSFmyYnsEVSUwlSXhqZ4sbnJtnUe2xfSXovrvNcwypzjah8o5d0qvHml3.QAsF21ed89thc6HD5A";
                  authorization_policy = "one_factor";
                  redirect_uris = [
                    "https://immich.${top.config.homelab.domain}/auth/login"
                    "https://immich.${top.config.homelab.domain}/user-settings"
                    "app.immich:///oauth-callback"
                  ];
                  scopes = [
                    "openid"
                    "profile"
                    "email"
                  ];
                  token_endpoint_auth_method = "client_secret_post";
                }
              ];
            };

          };
        };
        secrets = {
          sessionSecretFile = config.age.secrets."auth-session".path;
          jwtSecretFile = config.age.secrets."auth-jwt".path;
          storageEncryptionKeyFile = config.age.secrets."auth-enc".path;
          oidcHmacSecretFile = config.age.secrets."auth-oidc-hmac".path;
          oidcIssuerPrivateKeyFile = config.age.secrets."auth-oidc-jwk-key".path;
        };
      };

      services.redis.servers.authelia = {
        enable = true;
        port = 3240;
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
            # Fix invaild auth header error
            # (llumen)
            authRequestHeaders = [
              "Cookie"
            ];
          };
        };
      };
    };
}

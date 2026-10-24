{pkgs}: let
  inherit (pkgs) lib;
  package = pkgs.callPackage ../packages/byond-authentication-bridge/package.nix {};
  domain = "byond-authentication-bridge.tgstation13.org";
  # lemon's database keeps bab's tables in a schema of their own, not public.
  schema = "byond-authentication-bridge";
  environmentFile = pkgs.writeText "bab-environment" ''
    BAB_DB_CONNECTION_STRING=postgresql://byond-authentication-bridge@localhost/byond-authentication-bridge?host=/run/postgresql&schema=${schema}
  '';
  # Pushes bab's schema the way its devUpdateDb script does, leaving no
  # migration history.
  pushSchema = pkgs.writeShellScript "bab-db-push" ''
    cd ${package}/lib/node_modules/bab
    DATABASE_URL=$BAB_DB_CONNECTION_STRING exec node_modules/.bin/prisma db push --skip-generate
  '';
  prismaEnv = lib.concatStringsSep " " (lib.mapAttrsToList (name: value: "${name}=${value}") package.prismaEnv);
in
  pkgs.testers.runNixOSTest {
    name = "byond-authentication-bridge";
    nodes.machine = {
      imports = [
        ../../systems/edge-nodes/modules/bab
        # agenix has no key to decrypt with in a test VM.
        {options.age.secrets = lib.mkOption {type = lib.types.attrsOf lib.types.anything;};}
      ];
      age.secrets.bab_db_connection_string.path = "${environmentFile}";
      # modules/postgres.nix keeps the data on /persist, which lemon already has.
      systemd.tmpfiles.rules = ["d /persist/postgres/data 0700 postgres postgres -"];
      security.acme = {
        acceptTerms = true;
        defaults = {
          email = "acme@example.invalid";
          webroot = "/var/lib/acme/acme-challenge";
        };
      };
      services.caddy.enable = true;
    };
    testScript = ''
      import json
      import shlex

      unit = "byond-authentication-bridge.service"
      migrations = int(machine.succeed("ls -d ${package}/lib/node_modules/bab/prisma/migrations/*/ | wc -l"))

      def psql(sql, database="byond-authentication-bridge"):
          options = shlex.quote('-c search_path="${schema}"')
          return machine.succeed(
              f"runuser -u postgres -- env PGOPTIONS={options} psql -d {database} -At -v ON_ERROR_STOP=1 -c {shlex.quote(sql)}"
          ).strip()

      def assert_logged(text):
          invocation = machine.succeed(f"systemctl show -P InvocationID {unit}").strip()
          machine.wait_until_succeeds(
              f"journalctl -o cat _SYSTEMD_INVOCATION_ID={invocation} | grep -F {shlex.quote(text)}", timeout=30
          )

      def assert_migrated():
          assert psql("SELECT count(*) FROM _prisma_migrations WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL") == str(migrations)

      def assert_serves():
          psql("""INSERT INTO "Client" ("clientId", "redirectUris", "contactInfo", "desc") VALUES ('vmtest', ARRAY['https://client.invalid/cb'], 'vmtest', 'vmtest') ON CONFLICT DO NOTHING""")
          psql("""INSERT INTO "SigningKey" ("private", "public", "id", "active") VALUES ('{}', '{"kid": "vmtest"}', 'vmtest', true) ON CONFLICT DO NOTHING""")
          machine.wait_for_open_port(12385)
          machine.wait_for_open_port(443)
          keys = {"keys": [{"kid": "vmtest"}]}
          assert json.loads(machine.succeed("curl -sSf http://127.0.0.1:12385/auth/keys")) == keys
          assert json.loads(machine.succeed(
              "curl -sSf --cacert /var/lib/acme/.minica/cert.pem --resolve ${domain}:443:127.0.0.1 https://${domain}/auth/keys"
          )) == keys
          before = int(psql('SELECT count(*) FROM "Authorization"'))
          location = machine.succeed(
              "curl -sS -o /dev/null -w '%{redirect_url}' 'http://127.0.0.1:12385/auth/authorize?client_id=vmtest&redirect_uri=https%3A%2F%2Fclient.invalid%2Fcb&scope=openid&response_type=code'"
          )
          assert location.startswith("https://secure.byond.com/login.cgi?"), location
          assert int(psql('SELECT count(*) FROM "Authorization"')) == before + 1

      def stop():
          machine.succeed(f"timeout 30 systemctl stop {unit}")
          assert machine.succeed(f"systemctl show -P Result {unit}").strip() == "success"

      def recreate_database():
          stop()
          psql('DROP DATABASE "byond-authentication-bridge"', database="postgres")
          psql('CREATE DATABASE "byond-authentication-bridge" OWNER "byond-authentication-bridge"', database="postgres")

      with subtest("a fresh database is migrated"):
          machine.wait_for_unit(unit)
          assert_logged("All migrations have been successfully applied.")
          assert_migrated()
          assert_serves()

      with subtest("a restart migrates nothing"):
          stop()
          machine.succeed(f"systemctl start {unit}")
          assert_logged("No pending migrations to apply.")
          assert_migrated()
          assert_serves()

      with subtest("a pushed schema without history is baselined"):
          recreate_database()
          machine.succeed(
              "systemd-run --wait --pipe --quiet -p DynamicUser=yes -p User=byond-authentication-bridge"
              " -p EnvironmentFile=${environmentFile} -p Environment=${lib.escapeShellArg prismaEnv} ${pushSchema}"
          )
          assert psql("SELECT to_regclass('_prisma_migrations') IS NULL") == "t"
          machine.succeed(f"systemctl start {unit}")
          assert_logged("Migration 20211211063436_initial marked as applied.")
          assert_logged("No pending migrations to apply.")
          assert_migrated()
          assert_serves()

      with subtest("a drifted schema without history fails the unit"):
          stop()
          psql("DROP TABLE _prisma_migrations")
          psql('ALTER TABLE "Client" ADD COLUMN "drift" TEXT')
          machine.fail(f"systemctl start {unit}")
          assert_logged('ALTER TABLE "Client" DROP COLUMN "drift";')
          assert_logged("is not baselined")
          assert psql("SELECT to_regclass('_prisma_migrations') IS NULL") == "t"
    '';
  }

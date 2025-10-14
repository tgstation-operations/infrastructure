{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}: let
  uploadsDir = "/persist/mediawiki/uploads";
  mediawikiVersion = "1.43.0";

  vector-assets = pkgs.fetchFromGitHub {
    owner = "tgstation";
    repo = "vector-assets";
    rev = "4c9427c372dc81702743e8bf86961767ba92c8de";
    hash = "sha256-3kQDbFW1SfZcyfh9xXMhpru03JBS/d/091psPbTIRCw=";
  };
in {
  disabledModules = ["services/web-apps/mediawiki.nix"];
  imports = [
    ./module.nix
  ];

  services.mediawiki = {
    enable = true;
    package = pkgs.mediawiki.overrideAttrs (old: rec {
      name = "tgstation-mediawiki";
      version = mediawikiVersion;
      src = pkgs.fetchurl {
        url = "https://releases.wikimedia.org/mediawiki/${lib.versions.majorMinor version}/mediawiki-${version}.tar.gz";
        hash = "sha256-VuCn/i/3jlC5yHs9WJ8tjfW8qwAY5FSypKI5yFhr2O4=";
      };
      postInstall =
        (
          if old ? "postInstall"
          then old.postInstall
          else ""
        )
        + ''
          mkdir -p $out/share/mediawiki/resources/assets/thumb
          ln -s ${vector-assets}/* $out/share/mediawiki/resources/assets/thumb
        '';
    });

    name = "/tg/station 13 Wiki";
    url = "https://wiki.tgstation13.org";
    webserver = "none"; # manual caddy setup

    database = {
      type = "mysql";
      name = "wiki";
      user = "wiki";
      socket = "/run/mysqld/mysqld.sock";
      createLocally = false;
    };

    extensions = with pkgs; {
      DisableAccount = fetchgit {
        url = "https://gerrit.wikimedia.org/r/mediawiki/extensions/DisableAccount.git";
        rev = "155f4b3912f973cecaa95c68c377ec537b41d2c4";
        hash = "sha256-DTNtqYvl7eLR1WjVnhIuSzhrXc2TpryKUsK2m+P2uuI=";
      };
      PluggableAuth = fetchgit {
        url = "https://gerrit.wikimedia.org/r/mediawiki/extensions/PluggableAuth.git";
        rev = "fd63faae60460707dc0ac04279a39e81543f4518";
        hash = "sha256-aykCJ6vbpWIvxhBfLqURZ4HU0ELiz+sSfNQxD7cGRVQ=";
      };
      Tabs = applyPatches {
        src = fetchgit {
          url = "https://gerrit.wikimedia.org/r/mediawiki/extensions/Tabs.git";
          rev = "49e302f30ba6fee7f67b25644a66835c693fe168";
          hash = "sha256-ngY2Cp13znoWxSfLAoawrq8gx8ORl0mvR1YgpIpoDoI=";
        };
        patches = [
          (fetchurl
            {
              url = "https://github.com/gbeine/mediawiki-extensions-Tabs/commit/2311b879cd86b2eb5424e0e06194e7cea98f7f74.patch";
              hash = "sha256-MObXC4VcJlOfBEXKoiV9ihsMEIsXcHIRQewzn6no/Og=";
            })
        ];
      };
      UserMerge = fetchgit {
        url = "https://gerrit.wikimedia.org/r/mediawiki/extensions/UserMerge.git";
        rev = "a89e96396fc9c3b3a0637552ef35fa092081ac65";
        hash = "sha256-XKmlNf70cNbInXdNlZ4JaAn9vwWIp2/kGRUNb5dXfYM=";
      };
      WSOAuth = stdenvNoCC.mkDerivation {
        name = "WSOAuth-with-tgstation";
        src = fetchgit {
          url = "https://gerrit.wikimedia.org/r/mediawiki/extensions/WSOAuth.git";
          rev = "bd760054b379bdac54cb430cfe3554e59b01d559";
          hash = "sha256-01Yx3WjxtFkr3VzvZZYF4HuadXw1kHSlJZAg3IA2gPI=";
        };
        phases = ["unpackPhase" "patchPhase" "installPhase"];
        patchPhase = ''
          echo "${builtins.readFile ./TgForumAuthProvider.php}" > src/AuthenticationProvider/TgForumAuthProvider.php
        '';
        installPhase = ''
          mkdir -p $out
          cp -r ./* $out
        '';
      };
      ParserFunctions = null;
      TitleBlacklist = null;
      VisualEditor = null;
      WikiEditor = null;
    };
    user = "php-caddy";
    group = "php-caddy";
    extraConfig = ''
      ## Secret key
      $wgSecretKey = $_ENV['WIKI_SECRET_KEY'];
      $wgDBpassword = $_ENV['WIKI_DB_PASSWORD'];

      ## Short URL options
      $wgArticlePath = "/$1";

      $actions = ['view', 'edit', 'watch', 'unwatch', 'delete','revert', 'rollback', 'protect', 'unprotect', 'markpatrolled', 'render', 'submit', 'history', 'purge', 'info'];

      foreach ( $actions as $action ) {
          $wgActionPaths[$action] = "/$action/$1";
      }

      ## Database extra options
      $wgDBssl = false;

      ## Email options
      $wgEnableEmail = false;
      $wgEnableUserEmail = true;
      $wgEnotifUserTalk = false; # UPO
      $wgEnotifWatchlist = false; # UPO
      $wgEmailAuthentication = true;

      ## Shared memory settings
      $wgMainCacheType = CACHE_ACCEL;
      $wgSessionCacheType = CACHE_DB;
      $wgParserCacheType = CACHE_DB; // recommended by mediawiki
      $wgMemCachedServers = [ 'unix:///run/memcached/memcached.socket' ];

      ## Extra pages
      $wgRightsPage = "TG13:Privacy policy"; # Set to the title of a wiki page that describes your license/copyright
      $wgMetaNamespace = "TG13";

      ## Cache options
      $wgFileCacheDirectory = $wgCacheDirectory;
      $wgEnableSidebarCache = true;
      $wgUseFileCache = true;
      $wgShowIPinHeader = false;
      $wgEnableParserCache = true;
      $wgCachePages = true;

      ## Site upgrade key. Must be set to a string (default provided) to turn on the
      ## web installer while LocalSettings.php is in place
      $wgUpgradeKey = false;

      ## The URL paths to the logo.  Make sure you change this from the default,
      ## or else you'll overwrite your logo when you upgrade!
      $wgLogos = [ 'svg' => "$wgResourceBasePath/resources/assets/thumb/tg-star.svg" ];

      ## Favicon
      $wgFavicon = "$wgResourceBasePath/resources/assets/thumb/tg-star.ico";

      ## Miscellaneous settings

      $wgJobRunRate = 0.02;
      $wgUrlProtocols[] = "byond://";
      $wgMaxShellMemory = 512000;
      $wgMaxImageArea = 250000000;
      $wgLocaltimezone = "UTC";

      ## Custom Namespaces
      define("NS_TGMC", 4200); // This MUST be even.
      define("NS_TGMC_TALK", 4201); // This MUST be the following odd integer.

      $wgExtraNamespaces[NS_TGMC] = "TGMC";
      $wgExtraNamespaces[NS_TGMC_TALK] = "TGMC Talk";

      ## Group Permissions

      $wgGroupPermissions['*']['read'] = true;
      $wgGroupPermissions['*']['edit'] = false;
      $wgGroupPermissions['*']['createaccount'] = false;
      $wgGroupPermissions['*']['autocreateaccount'] = true;
      $wgGroupPermissions['*']['editmyprivateinfo'] = false;
      $wgGroupPermissions['*']['viewmyprivateinfo'] = false;

      $wgGroupPermissions['user']['edit'] = true;
      $wgGroupPermissions['user']['move'] = false;
      $wgGroupPermissions['user']['editmyusercss'] = false;
      $wgGroupPermissions['user']['editmyuserjs'] = false;
      $wgGroupPermissions['user']['editmyuserjsredirect'] = false;
      $wgGroupPermissions['user']['editmyuserjson'] = false;
      $wgGroupPermissions['user']['sendemail'] = false;

      $wgGroupPermissions['WikiJannie'] = $wgGroupPermissions['suppress'];
      $wgGroupPermissions['WikiJannie']['protect'] = true;
      $wgGroupPermissions['WikiJannie']['editprotected'] = true;
      $wgGroupPermissions['WikiJannie']['move'] = true;
      $wgGroupPermissions['WikiJannie']['delete'] = true;
      $wgGroupPermissions['WikiJannie']['undelete'] = true;
      $wgGroupPermissions['WikiJannie']['deletedhistory'] = true;
      $wgGroupPermissions['WikiJannie']['deletedtext'] = true;
      $wgGroupPermissions['WikiJannie']['browsearchive'] = true;
      $wgGroupPermissions['WikiJannie']['rollback'] = true;

      $wgGroupPermissions['HeadAdministrator'] = $wgGroupPermissions['WikiJannie'];

      $wgGroupPermissions['bureaucrat']['usermerge'] = true;
      $wgGroupPermissions['bureaucrat']['disableaccount'] = true;

      ## Authentication options

      $wgPasswordResetRoutes = false;
      $wgPasswordConfig['null'] = [ 'class' => InvalidPassword::class ];

      $wgOAuthCustomAuthProviders = [
        'tgforum' => \WSOAuth\AuthenticationProvider\TgForumAuthProvider::class
      ];

      $wgPluggableAuth_Config['tgforum'] = [
        'plugin' => 'WSOAuth',
        'data' => [
          'type' => 'tgforum',
          'clientId' => (int) $_ENV['WIKI_OAUTH2_CLIENT_ID'],
          'clientSecret' => $_ENV['WIKI_OAUTH2_CLIENT_SECRET'],
        ],
      ];
    '';
    passwordSender = "apache@🌻.invalid";
  };

  systemd.services.mediawiki-init = {
    environment = {MEDIAWIKI_CONFIG = config.services.phpfpm.pools.mediawiki.phpEnv.MEDIAWIKI_CONFIG;};
  };

  services.phpfpm.pools.mediawiki = {}; # delete unused phpfpm pool thats created by services.mediawiki
}

({website,authfile,...}:{config,pkgs,...}:
let

  perlWithModules = pkgs.perl.withPackages (ps: with ps; [
    CGI
    FCGI
    DBDMariaDB
    DBI
  ]);

  script = pkgs.writeScript "admin-2fa.pl" ''
  #!${perlWithModules}/bin/perl
  use strict;
  use warnings;
  use FCGI;
  use DBI;

  my $handling_request = 0;
  my $exit_requested = 0;

  my $request = FCGI::Request();
  
  # cant say I know a whole lot about fastcgi boilerplate, I'm more used to just apache+cgi
  sub sig_handler {
      $exit_requested = 1;
      exit(0) if !$handling_request;
  }
  
  $SIG{USR1} = \&sig_handler;
  $SIG{TERM} = \&sig_handler;
  $SIG{PIPE} = 'IGNORE';
  
  while ($handling_request = ($request->Accept() >= 0)) {
      &do_request;
  
      $handling_request = 0;
      last if $exit_requested;
  }
  
  $request->Finish();
  
  exit(0);
  
  sub do_request() {
      print("Content-type: text/html\r\n\r\n");
      print("<html><head><title>Admin Two Factor Authentication Endpoint</title></head></body>");
      print("<h1 align=center>Admin 2FA Endpoint</h1>");

      # grab the row ID passed by the game, strip it down to its numeric component
      my $query = $ENV{QUERY_STRING};
      $query = "" if (!defined($query));
      if ($query=~/^id=(\d+)$/) { $query=$1; }

      # grab the username from authentik
      my $authentik_id = $ENV{HTTP_X_AUTHENTIK_USERNAME};
      $authentik_id = "" if (!defined($authentik_id));

      #grab the remote ip - probably need to change this header to be some proxy inserted header (?)
      my $remote = $ENV{REMOTE_ADDR};
      if (!defined($remote)) { $remote=""; }

      # some basic requirements
      if ($authentik_id eq "") {
        fail("No Authentik user ID was found ; this is fatal, please contact ops"); return;
      }
      if (!($query=~/^\d+$/)) {
        fail("The two factor authentication ID number does not appear to be a number"); return;
      }
 
      # time to get real and read our DB creds
      open DB,"/run/agenix/admin_2fa_db";
      my $dbhost=<DB>; chomp $dbhost;
      my $dbuser=<DB>; chomp $dbuser;
      my $dbpass=<DB>; chomp $dbpass;
      my $dbname=<DB>; chomp $dbname;
      my $dbtable=<DB>; chomp $dbtable;
      close DB;

      # connect to DB
      my $dbh = DBI->connect("DBI:MariaDB:database=$dbname;host=$dbhost",$dbuser,$dbpass);
      if (!$dbh) { fail("Database connection failed: ".DBI->errstr()); return; }

      # pull the row we're supposed to be authorising and dedecimalise the IP
      my $dbq = $dbh->prepare("select ckey,INET_NTOA(ip) as ip,cid,verification_time from $dbtable where id=?");
      $dbq -> execute($query);
      my $hashref = $dbq -> fetchrow_hashref;
      my %db = %{$hashref}; 
      $dbq -> finish();

      # some sanity checking ; request must not already be verified ; ckey must match authentik username ; can check the IP
      # IP checking is considered optional, our previous solution had a flag to bypass the matching requirement so there's a reason.
      # also IP checking needs to read the relevant proxy header earlier, probably
      if (lc($db{ckey}) ne lc($authentik_id)) {
        fail("User ID mismatch, are you messing around?  If not, please contact ops"); $dbh->disconnect(); return;
      }
      if ($db{ip} ne $remote) {
        fail("IP mismatch ; if you don't expect to see this please contact ops.<br><br>");
      }
      if (defined($db{verification_time})) {
        fail("This two factor request appears to already have been approved"); $dbh->disconnect(); return;
      }
     
      # well if we got this far...
      $dbq=$dbh->prepare("update $dbtable set verification_time=CURRENT_TIMESTAMP() where id=?");
      $dbq -> execute($query);
      $dbq -> finish();
      print("<font color=green><b>Your two factor authentication request has been approved, you can close this window and run verify-admin inside BYOND once more</b></font>");

      $dbh->disconnect();
      print("</body></html>"); $request->Finish();
  }
  sub fail() {
    my ($msg)=@_;
    print("<font color=red><b>$msg</b></font>");
    print("</body></html>"); $request->Finish();
  }
  '';

in {
  # This sets up a bunch of stuff to perform admin 2fa authentication
  services.caddy = {
    virtualHosts = {
      "${website}" = {
        extraConfig = ''
          route {
            reverse_proxy /outpost.goauthentik.io/* localhost:9000
            forward_auth https://auth.tgstation13.org {
              uri /outpost.goauthentik.io/auth/caddy
              copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Entitlements X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
            }
            reverse_proxy unix//run/admin-2fa.socket {
              transport fastcgi {
                split .pl
              }
            }
          }
        '';
      };
    };
  };

  systemd.services.admin-2fa-fcgi = {
    description = "Admin Two Factor Authentication Approver";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.spawn_fcgi}/bin/spawn-fcgi -n -s /run/admin-2fa.socket -U caddy -G caddy -- ${script}";
      Restart = "always";
    };
  }; 

  # database access, file should be, on separate lines
  #  DBHOST (probably tgsatan.tg.lan)
  #  DBUSER (probably admin2fa)
  #  DBPASS (something secret)
  #  DBNAME (e.g. tgstation13)
  #  DBTABLE (probably admin_connections, by tg schema, if you have no table prefix)
  # to set perms ; something like : grant select,update on tg.admin_connections to admin2fa@lemon.tg.lan identified by 'admin2fa';
  age.secrets.admin_2fa_db = {
    file = ./${authfile};
    owner = "caddy";
  };
})

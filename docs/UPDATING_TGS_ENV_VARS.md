# How to apply new TGS env vars

Changing the env vars for TGS (namely via`extra-path`) requires some additional fnagling.

1. Push the nix closure
2. Deploy across both staging and prod
3. On **wiggle** run `sudo systemctl restart tgstation-server`

The other production machines are more involved since the above command restarts game servers as well. The following steps must be applied to both tgsatan and blockmoths

4. Run `systemctl status tgstation-server`. Make note of the process ID with `Tgstation.Server.Host.Console.dll` in the command line arguments (**NOT** `Tgstation.Server.Host.dll`).
5. Run `sudo kill -9 <pid from above>`
6. Sign in to the TGS webpanel for the VM and go to Administration -> Restart Server
7. Run `sudo systemctl start tgstation-server`.

This is needed so the outer TGS process is restarted and gets the new env vars to pass to a new instance of the core TGS process

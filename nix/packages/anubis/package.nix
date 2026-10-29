{anubis}: let
  static = ../../../website/src/static;
in
  anubis.overrideAttrs (previousAttrs: {
    patches = [./branding.patch];
    # Upstream asks that deployments keep the Anubis character
    # (https://github.com/TecharoHQ/anubis/blob/v1.26.2/docs/docs/funding.md),
    # so it moves to the footer and Officer Beepsky takes the middle. Beepsky
    # is cut from tgstation's icons/mob/silicon/aibots.dmi (secbot1, secbot-c)
    # and icons/mob/simple/animal.dmi (heart), at the revision
    # website/sprites/sprites.toml names.
    postPatch =
      previousAttrs.postPatch
      + ''
        cp web/static/img/happy.webp web/static/img/anubis.webp
        cp ${./pensive.webp} web/static/img/pensive.webp
        cp ${./happy.webp} web/static/img/happy.webp
        cp ${./reject.webp} web/static/img/reject.webp
        cp ${static + "/tgstation13.png"} web/static/img/tgstation13.png
        cp ${static + "/firasans.woff2"} xess/static/firasans.woff2
        cp ${static + "/firacode.woff2"} xess/static/firacode.woff2
        cp ${static + "/layer1.webp"} xess/static/layer1.webp
      '';
  })

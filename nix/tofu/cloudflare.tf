locals {
  cloudflare_zone_id = "7b2f57bcf3eb933ef22b6b7832535686"

  # Keyed by name relative to the zone, type, and, where a name has several
  # records of a type, what tells them apart. ttl 1 is Cloudflare's automatic.
  cloudflare_records = {
    "@ CNAME"                                           = { name = "@", type = "CNAME", content = "lemon.tgstation13.org", proxied = true }
    "@ MX alt1.aspmx.l.google.com"                      = { name = "@", type = "MX", content = "alt1.aspmx.l.google.com", ttl = 3600, priority = 5 }
    "@ MX alt2.aspmx.l.google.com"                      = { name = "@", type = "MX", content = "alt2.aspmx.l.google.com", ttl = 3600, priority = 5 }
    "@ MX alt3.aspmx.l.google.com"                      = { name = "@", type = "MX", content = "alt3.aspmx.l.google.com", ttl = 3600, priority = 10 }
    "@ MX alt4.aspmx.l.google.com"                      = { name = "@", type = "MX", content = "alt4.aspmx.l.google.com", ttl = 3600, priority = 10 }
    "@ MX aspmx.l.google.com"                           = { name = "@", type = "MX", content = "aspmx.l.google.com", ttl = 3600, priority = 1 }
    "@ TXT brevo-code"                                  = { name = "@", type = "TXT", content = "\"brevo-code:04143306d8dd6c06cdc39b6233f4d5d8\"" }
    "@ TXT google-site-verification"                    = { name = "@", type = "TXT", content = "\"google-site-verification=V6bISpp89hDDQr49DThXX9LCGxGXNeWVnyotKfo7_e4\"", ttl = 3600 }
    "@ TXT protonmail-verification"                     = { name = "@", type = "TXT", content = "\"protonmail-verification=06d259e716f721d9e032ee0c93c46c45cdcca281\"" }
    "@ TXT spf1"                                        = { name = "@", type = "TXT", content = "\"v=spf1 include:_spf.google.com include:amazonses.com include:spf.brevo.com -all\"", ttl = 3600 }
    "2fa CNAME"                                         = { name = "2fa", type = "CNAME", content = "lemon.tgstation13.org", proxied = true }
    "2fa-staging CNAME"                                 = { name = "2fa-staging", type = "CNAME", content = "wiggle.tg.lan" }
    "_atproto TXT"                                      = { name = "_atproto", type = "TXT", content = "\"did=did:plc:lsemx47wrx4izbfubapz2csn\"", comment = "Bluesky Handle Domain Verification" }
    "_dmarc TXT"                                        = { name = "_dmarc", type = "TXT", content = "\"v=DMARC1; p=reject; rua=mailto:rua@dmarc.brevo.com\"" }
    "3mnlnd4i2jpq7hq5k23slnczu7eceywn._domainkey CNAME" = { name = "3mnlnd4i2jpq7hq5k23slnczu7eceywn._domainkey", type = "CNAME", content = "3mnlnd4i2jpq7hq5k23slnczu7eceywn.dkim.amazonses.com", ttl = 300 }
    "brevo1._domainkey CNAME"                           = { name = "brevo1._domainkey", type = "CNAME", content = "b1.tgstation13-org.dkim.brevo.com", ttl = 3600 }
    "brevo2._domainkey CNAME"                           = { name = "brevo2._domainkey", type = "CNAME", content = "b2.tgstation13-org.dkim.brevo.com", ttl = 3600 }
    "k3qzzmw64453ixrklfjfheqk5754eix2._domainkey CNAME" = { name = "k3qzzmw64453ixrklfjfheqk5754eix2._domainkey", type = "CNAME", content = "k3qzzmw64453ixrklfjfheqk5754eix2.dkim.amazonses.com", ttl = 300 }
    "protonmail._domainkey CNAME"                       = { name = "protonmail._domainkey", type = "CNAME", content = "protonmail.domainkey.dvtwtrvhvhvcdu67eu2h62yaqpmffr5hhg26kr6qk33ibk55iww7a.domains.proton.ch" }
    "protonmail2._domainkey CNAME"                      = { name = "protonmail2._domainkey", type = "CNAME", content = "protonmail2.domainkey.dvtwtrvhvhvcdu67eu2h62yaqpmffr5hhg26kr6qk33ibk55iww7a.domains.proton.ch" }
    "protonmail3._domainkey CNAME"                      = { name = "protonmail3._domainkey", type = "CNAME", content = "protonmail3.domainkey.dvtwtrvhvhvcdu67eu2h62yaqpmffr5hhg26kr6qk33ibk55iww7a.domains.proton.ch" }
    "zx2hvee7kz4t5spcn7oi434nhm6os6yy._domainkey CNAME" = { name = "zx2hvee7kz4t5spcn7oi434nhm6os6yy._domainkey", type = "CNAME", content = "zx2hvee7kz4t5spcn7oi434nhm6os6yy.dkim.amazonses.com", ttl = 300 }
    "attic CNAME"                                       = { name = "attic", type = "CNAME", content = "tgsatan.vpn.tgstation13.org" }
    "auth CNAME"                                        = { name = "auth", type = "CNAME", content = "lemon.tgstation13.org", proxied = true }
    "byond-authentication-bridge CNAME"                 = { name = "byond-authentication-bridge", type = "CNAME", content = "lemon.tgstation13.org", proxied = true }
    "codedocs CNAME"                                    = { name = "codedocs", type = "CNAME", content = "tgstation.github.io" }
    "cool CNAME"                                        = { name = "cool", type = "CNAME", content = "blockmoths.eu.tgstation13.org" }
    "effigy CNAME"                                      = { name = "effigy", type = "CNAME", content = "tgsatan.us.tgstation13.org" }
    "effigy-logs CNAME"                                 = { name = "effigy-logs", type = "CNAME", content = "dfdeb88f-c4e3-43a9-8964-a23f97dc3832.cfargotunnel.com", proxied = true }
    "eu NS"                                             = { name = "eu", type = "NS", content = "ns-1071.awsdns-05.org" }
    "tgs.blockmoths.eu CNAME"                           = { name = "tgs.blockmoths.eu", type = "CNAME", content = "blockmoths.tg.lan" }
    "eventhall CNAME"                                   = { name = "eventhall", type = "CNAME", content = "tgsatan.us.tgstation13.org" }
    "eventhallus-logs CNAME"                            = { name = "eventhallus-logs", type = "CNAME", content = "dfdeb88f-c4e3-43a9-8964-a23f97dc3832.cfargotunnel.com", proxied = true }
    "eventus-logs CNAME"                                = { name = "eventus-logs", type = "CNAME", content = "dfdeb88f-c4e3-43a9-8964-a23f97dc3832.cfargotunnel.com", proxied = true }
    "forums CNAME"                                      = { name = "forums", type = "CNAME", content = "lemon.tgstation13.org", proxied = true }
    "funnyname-logs CNAME"                              = { name = "funnyname-logs", type = "CNAME", content = "24ae9f0d-7cc5-46bb-9fdd-7f1cd0ddb11a.cfargotunnel.com", proxied = true }
    "garage CNAME"                                      = { name = "garage", type = "CNAME", content = "tgsatan.vpn.tgstation13.org" }
    "github-webhooks CNAME"                             = { name = "github-webhooks", type = "CNAME", content = "lemon.tgstation13.org", proxied = true }
    "lemon A"                                           = { name = "lemon", type = "A", content = "51.79.52.10", proxied = true }
    "lime A"                                            = { name = "lime", type = "A", content = "15.204.224.136", proxied = true }
    "mail MX"                                           = { name = "mail", type = "MX", content = "feedback-smtp.us-east-1.amazonses.com", priority = 10 }
    "manuel CNAME"                                      = { name = "manuel", type = "CNAME", content = "tgsatan.us.tgstation13.org" }
    "manuel-2 CNAME"                                    = { name = "manuel-2", type = "CNAME", content = "tgsatan.us.tgstation13.org" }
    "manuel-logs CNAME"                                 = { name = "manuel-logs", type = "CNAME", content = "dfdeb88f-c4e3-43a9-8964-a23f97dc3832.cfargotunnel.com", proxied = true }
    "manuel2-logs CNAME"                                = { name = "manuel2-logs", type = "CNAME", content = "dfdeb88f-c4e3-43a9-8964-a23f97dc3832.cfargotunnel.com", proxied = true }
    "netbird CNAME"                                     = { name = "netbird", type = "CNAME", content = "vpn.tgstation13.org", ttl = 300 }
    "opencollective CNAME"                              = { name = "opencollective", type = "CNAME", content = "81829d31-62fd-4cb0-9f82-f91eb6385a38.cfargotunnel.com", proxied = true }
    "raw-effigy-logs CNAME"                             = { name = "raw-effigy-logs", type = "CNAME", content = "dfdeb88f-c4e3-43a9-8964-a23f97dc3832.cfargotunnel.com", proxied = true }
    "raw-eventhallus-logs CNAME"                        = { name = "raw-eventhallus-logs", type = "CNAME", content = "dfdeb88f-c4e3-43a9-8964-a23f97dc3832.cfargotunnel.com", proxied = true }
    "raw-funnyname-logs CNAME"                          = { name = "raw-funnyname-logs", type = "CNAME", content = "24ae9f0d-7cc5-46bb-9fdd-7f1cd0ddb11a.cfargotunnel.com", proxied = true }
    "raw-manuel-logs CNAME"                             = { name = "raw-manuel-logs", type = "CNAME", content = "dfdeb88f-c4e3-43a9-8964-a23f97dc3832.cfargotunnel.com", proxied = true }
    "raw-manuel2-logs CNAME"                            = { name = "raw-manuel2-logs", type = "CNAME", content = "dfdeb88f-c4e3-43a9-8964-a23f97dc3832.cfargotunnel.com", proxied = true }
    "raw-sybil-logs CNAME"                              = { name = "raw-sybil-logs", type = "CNAME", content = "dfdeb88f-c4e3-43a9-8964-a23f97dc3832.cfargotunnel.com", proxied = true }
    "raw-terry-logs CNAME"                              = { name = "raw-terry-logs", type = "CNAME", content = "276b7e4a-f91c-4b23-8060-78a0a1542e8d.cfargotunnel.com", proxied = true }
    "raw-tgmc-logs CNAME"                               = { name = "raw-tgmc-logs", type = "CNAME", content = "dfdeb88f-c4e3-43a9-8964-a23f97dc3832.cfargotunnel.com", proxied = true }
    "rsc CNAME"                                         = { name = "rsc", type = "CNAME", content = "public.r2.dev", proxied = true }
    "s3 CNAME"                                          = { name = "s3", type = "CNAME", content = "tgsatan.vpn.tgstation13.org" }
    "funnyname.staging CNAME"                           = { name = "funnyname.staging", type = "CNAME", content = "wiggle.tg.lan" }
    "web.staging CNAME"                                 = { name = "web.staging", type = "CNAME", content = "warsaw.vpn.tgstation13.org" }
    "tgs.wiggle.staging CNAME"                          = { name = "tgs.wiggle.staging", type = "CNAME", content = "wiggle.vpn.tgstation13.org" }
    "sybil CNAME"                                       = { name = "sybil", type = "CNAME", content = "tgsatan.us.tgstation13.org" }
    "sybil-logs CNAME"                                  = { name = "sybil-logs", type = "CNAME", content = "dfdeb88f-c4e3-43a9-8964-a23f97dc3832.cfargotunnel.com", proxied = true }
    "terry CNAME"                                       = { name = "terry", type = "CNAME", content = "blockmoths.eu.tgstation13.org" }
    "terry-logs CNAME"                                  = { name = "terry-logs", type = "CNAME", content = "276b7e4a-f91c-4b23-8060-78a0a1542e8d.cfargotunnel.com", proxied = true }
    "tgmc CNAME"                                        = { name = "tgmc", type = "CNAME", content = "tgsatan.us.tgstation13.org" }
    "us NS"                                             = { name = "us", type = "NS", content = "ns-362.awsdns-45.com", ttl = 300 }
    "tgs.tgsatan.us CNAME"                              = { name = "tgs.tgsatan.us", type = "CNAME", content = "tgsatan.tg.lan" }
    "vpn A"                                             = { name = "vpn", type = "A", content = "144.202.94.16" }
    "tgsatan.vpn A"                                     = { name = "tgsatan.vpn", type = "A", content = "100.13.161.130" }
    "warsaw.vpn A"                                      = { name = "warsaw.vpn", type = "A", content = "100.64.0.140" }
    "wiggle.vpn A"                                      = { name = "wiggle.vpn", type = "A", content = "100.64.0.25" }
    "wiki CNAME"                                        = { name = "wiki", type = "CNAME", content = "lemon.tgstation13.org", proxied = true }
  }
}

resource "cloudflare_dns_record" "tgstation13_org" {
  for_each = local.cloudflare_records

  zone_id  = local.cloudflare_zone_id
  name     = each.value.name == "@" ? "tgstation13.org" : "${each.value.name}.tgstation13.org"
  type     = each.value.type
  content  = each.value.content
  ttl      = try(each.value.ttl, 1)
  proxied  = try(each.value.proxied, false)
  priority = try(each.value.priority, null)
  comment  = try(each.value.comment, null)
}

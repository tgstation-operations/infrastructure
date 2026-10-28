locals {
  route53_zone_ids = {
    eu = "Z01047421LLCOPCJSWJ2Y"
    us = "Z10050436TI91Z12FNGG"
  }

  # The us and eu zones are delegated from Cloudflare's. Their apex NS and SOA
  # records belong to the hosted zones and are left to Route53.
  route53_records = {
    "blockmoths.eu A bratwurst" = { zone = "eu", name = "blockmoths.eu", type = "A", ttl = 300, records = ["159.69.40.186"], set_identifier = "bratwurst", multivalue = true }
    "blockmoths.eu A knipp"     = { zone = "eu", name = "blockmoths.eu", type = "A", ttl = 300, records = ["188.245.253.9"], set_identifier = "knipp", multivalue = true }
    "s3.blockmoths.eu A"        = { zone = "eu", name = "s3.blockmoths.eu", type = "A", ttl = 300, records = ["100.64.0.11"] }
    "admin.s3.blockmoths.eu A"  = { zone = "eu", name = "admin.s3.blockmoths.eu", type = "A", ttl = 300, records = ["100.64.0.11"] }
    "s3-web.blockmoths.eu A"    = { zone = "eu", name = "s3-web.blockmoths.eu", type = "A", ttl = 300, records = ["100.64.0.11"] }
    "tgs.blockmoths.eu A"       = { zone = "eu", name = "tgs.blockmoths.eu", type = "A", ttl = 300, records = ["100.64.0.11"] }
    "tgsatan.us A Atlanta"      = { zone = "us", name = "tgsatan.us", type = "A", ttl = 300, records = ["155.138.214.204"], set_identifier = "Atlanta", geoproximity = { latitude = "33.75", longitude = "-84.38", bias = 0 } }
    "tgsatan.us A Dallas"       = { zone = "us", name = "tgsatan.us", type = "A", ttl = 300, records = ["108.61.222.116"], set_identifier = "Dallas", geoproximity = { latitude = "32.77", longitude = "-96.80", bias = 0 } }
    "s3.tgsatan.us A"           = { zone = "us", name = "s3.tgsatan.us", type = "A", ttl = 300, records = ["100.64.0.1"] }
    "admin.s3.tgsatan.us A"     = { zone = "us", name = "admin.s3.tgsatan.us", type = "A", ttl = 300, records = ["100.64.0.1"] }
    "s3-web.tgsatan.us A"       = { zone = "us", name = "s3-web.tgsatan.us", type = "A", ttl = 300, records = ["100.64.0.1"] }
    "tgs.tgsatan.us A"          = { zone = "us", name = "tgs.tgsatan.us", type = "A", ttl = 300, records = ["100.64.0.1"] }
  }
}

resource "aws_route53_record" "this" {
  for_each = local.route53_records

  zone_id                          = local.route53_zone_ids[each.value.zone]
  name                             = "${each.value.name}.tgstation13.org"
  type                             = each.value.type
  ttl                              = each.value.ttl
  records                          = each.value.records
  set_identifier                   = try(each.value.set_identifier, null)
  multivalue_answer_routing_policy = try(each.value.multivalue, null)

  dynamic "geoproximity_routing_policy" {
    for_each = try([each.value.geoproximity], [])
    content {
      bias = geoproximity_routing_policy.value.bias
      coordinates {
        latitude  = geoproximity_routing_policy.value.latitude
        longitude = geoproximity_routing_policy.value.longitude
      }
    }
  }
}

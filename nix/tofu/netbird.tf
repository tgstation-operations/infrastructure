data "netbird_peer" "this" {
  for_each = toset(["atlanta", "blockmoths", "bratwurst", "chicago", "dachshund", "dallas", "grob", "knipp", "lemon", "tgsatan", "vpn", "warsaw", "wiggle"])
  name     = each.key
}

data "netbird_group" "all" {
  name = "All"
}

resource "netbird_group" "attic_enjoyer" {
  name = "Attic Enjoyer"
}

resource "netbird_group" "backend" {
  name = "Backend"
  peers = [
    data.netbird_peer.this["vpn"].id,
    data.netbird_peer.this["lemon"].id,
    data.netbird_peer.this["blockmoths"].id,
    data.netbird_peer.this["tgsatan"].id,
  ]
}

resource "netbird_group" "ci" {
  name = "CI"
}

resource "netbird_group" "eu_relay" {
  name = "EU Relay"
  peers = [
    data.netbird_peer.this["bratwurst"].id,
    data.netbird_peer.this["dachshund"].id,
    data.netbird_peer.this["knipp"].id,
  ]
}

resource "netbird_group" "game_server" {
  name = "Game Server"
  peers = [
    data.netbird_peer.this["blockmoths"].id,
    data.netbird_peer.this["tgsatan"].id,
  ]
}

resource "netbird_group" "maria_garage_cluster" {
  name = "Maria/Garage Cluster"
  peers = [
    data.netbird_peer.this["blockmoths"].id,
    data.netbird_peer.this["tgsatan"].id,
  ]
}

resource "netbird_group" "operator" {
  name = "Operator"
  peers = [
    data.netbird_peer.this["grob"].id,
  ]
}

resource "netbird_group" "relay" {
  name = "Relay"
  peers = [
    data.netbird_peer.this["lemon"].id,
    data.netbird_peer.this["dallas"].id,
    data.netbird_peer.this["atlanta"].id,
    data.netbird_peer.this["chicago"].id,
    data.netbird_peer.this["bratwurst"].id,
    data.netbird_peer.this["dachshund"].id,
    data.netbird_peer.this["knipp"].id,
  ]
}

resource "netbird_group" "staging" {
  name = "Staging"
  peers = [
    data.netbird_peer.this["warsaw"].id,
    data.netbird_peer.this["wiggle"].id,
  ]
}

resource "netbird_group" "us_relay" {
  name = "US Relay"
  peers = [
    data.netbird_peer.this["lemon"].id,
    data.netbird_peer.this["dallas"].id,
    data.netbird_peer.this["atlanta"].id,
    data.netbird_peer.this["chicago"].id,
  ]
}

resource "netbird_group" "webserver" {
  name = "Webserver"
}

resource "netbird_policy" "all_hosts_to_atticd" {
  name    = "All Hosts to Atticd"
  enabled = true

  rule {
    name                 = "All Hosts to Atticd"
    action               = "accept"
    protocol             = "tcp"
    bidirectional        = false
    enabled              = true
    ports                = ["443"]
    sources              = [data.netbird_group.all.id]
    destination_resource = { type = "peer", id = data.netbird_peer.this["tgsatan"].id }
  }
}

resource "netbird_policy" "ci_to_attic" {
  name    = "CI to Attic"
  enabled = true

  rule {
    name                 = "CI to Attic"
    action               = "accept"
    protocol             = "tcp"
    bidirectional        = false
    enabled              = true
    ports                = ["80", "443"]
    sources              = [netbird_group.ci.id, netbird_group.attic_enjoyer.id]
    destination_resource = { type = "peer", id = data.netbird_peer.this["tgsatan"].id }
  }
}

resource "netbird_policy" "deploy_from_ci" {
  name    = "Deploy from CI"
  enabled = true

  rule {
    name          = "Deploy from CI"
    action        = "accept"
    protocol      = "tcp"
    bidirectional = false
    enabled       = true
    ports         = ["22"]
    sources       = [netbird_group.ci.id]
    destinations  = [data.netbird_group.all.id]
  }
}

resource "netbird_policy" "lemon_forums_database" {
  name    = "Lemon Forums Database"
  enabled = true

  rule {
    name                 = "Lemon Forums Database"
    action               = "accept"
    protocol             = "tcp"
    bidirectional        = false
    enabled              = true
    ports                = ["3306"]
    source_resource      = { type = "peer", id = data.netbird_peer.this["lemon"].id }
    destination_resource = { type = "peer", id = data.netbird_peer.this["tgsatan"].id }
  }
}

resource "netbird_policy" "lemon_game_server_status_scraping" {
  name    = "Lemon Game Server Status Scraping"
  enabled = true

  rule {
    name            = "Lemon Game Server Status Scraping"
    action          = "accept"
    protocol        = "tcp"
    bidirectional   = false
    enabled         = true
    ports           = ["1337", "1447", "1887", "3336", "5337", "7337", "7777"]
    source_resource = { type = "peer", id = data.netbird_peer.this["lemon"].id }
    destinations    = [netbird_group.game_server.id]
  }
}

resource "netbird_policy" "maria_garage_cluster" {
  name    = "Maria/Garage Cluster"
  enabled = true

  rule {
    name          = "Maria/Garage Cluster"
    action        = "accept"
    protocol      = "tcp"
    bidirectional = true
    enabled       = true
    ports         = ["3901", "3306"]
    sources       = [netbird_group.maria_garage_cluster.id]
    destinations  = [netbird_group.maria_garage_cluster.id]
  }
}

resource "netbird_policy" "operator_access" {
  name    = "Operator Access"
  enabled = true

  rule {
    name          = "Operator Access"
    action        = "accept"
    protocol      = "all"
    bidirectional = false
    enabled       = true
    sources       = [netbird_group.operator.id]
    destinations  = [data.netbird_group.all.id]
  }
}

resource "netbird_policy" "relay_game_server_game_traffic" {
  name    = "Relay => Game Server Game Traffic"
  enabled = true

  rule {
    name          = "Relay => Game Server Game Traffic"
    action        = "accept"
    protocol      = "tcp"
    bidirectional = false
    enabled       = true
    ports         = ["11337", "11447", "11887", "13336", "15337", "17337", "17777", "18085"]
    sources       = [netbird_group.relay.id]
    destinations  = [netbird_group.game_server.id]
  }
}

resource "netbird_policy" "tgsatan_prometheus_scrapers" {
  name    = "TGSatan Prometheus Scrapers"
  enabled = true

  rule {
    name            = "TGSatan Prometheus Scrapers"
    action          = "accept"
    protocol        = "tcp"
    bidirectional   = false
    enabled         = true
    ports           = ["5001", "5004", "8405", "9100", "9558"]
    source_resource = { type = "peer", id = data.netbird_peer.this["tgsatan"].id }
    destinations    = [data.netbird_group.all.id]
  }
}

resource "netbird_policy" "warsaw_wiggle_game_traffic" {
  name    = "Warsaw => Wiggle Game Traffic"
  enabled = true

  rule {
    name                 = "Warsaw => Wiggle Game Traffic"
    action               = "accept"
    protocol             = "tcp"
    bidirectional        = false
    enabled              = true
    ports                = ["8085", "8989", "18085", "18989"]
    source_resource      = { type = "peer", id = data.netbird_peer.this["warsaw"].id }
    destination_resource = { type = "peer", id = data.netbird_peer.this["wiggle"].id }
  }
}

resource "netbird_setup_key" "agenix_key" {
  name        = "Agenix Key"
  type        = "reusable"
  ephemeral   = false
  auto_groups = [netbird_group.backend.id]

  lifecycle {
    # A new key would orphan the copy the hosts or CI enrol with.
    prevent_destroy = true
  }
}

resource "netbird_setup_key" "ci_attic_only" {
  name        = "CI Attic Only"
  type        = "reusable"
  ephemeral   = true
  auto_groups = [netbird_group.attic_enjoyer.id]

  lifecycle {
    # A new key would orphan the copy the hosts or CI enrol with.
    prevent_destroy = true
  }
}

resource "netbird_setup_key" "ci_deployment_key" {
  name        = "CI Deployment Key"
  type        = "reusable"
  ephemeral   = true
  auto_groups = [netbird_group.ci.id]

  lifecycle {
    # A new key would orphan the copy the hosts or CI enrol with.
    prevent_destroy = true
  }
}

resource "netbird_setup_key" "relay_key" {
  name        = "Relay Key"
  type        = "reusable"
  ephemeral   = false
  auto_groups = [netbird_group.relay.id]

  lifecycle {
    # A new key would orphan the copy the hosts or CI enrol with.
    prevent_destroy = true
  }
}

resource "netbird_setup_key" "staging_key" {
  name        = "Staging Key"
  type        = "reusable"
  ephemeral   = false
  auto_groups = [netbird_group.staging.id]

  lifecycle {
    # A new key would orphan the copy the hosts or CI enrol with.
    prevent_destroy = true
  }
}

resource "netbird_network" "blockmoths_egress" {
  name = "Blockmoths Egress"
}

resource "netbird_network_router" "blockmoths_egress" {
  network_id  = netbird_network.blockmoths_egress.id
  peer_groups = [netbird_group.eu_relay.id]
  masquerade  = true
  metric      = 9999
  enabled     = true
}

resource "netbird_network" "tgsatan_egress" {
  name = "TGSatan Egress"
}

resource "netbird_network_router" "tgsatan_egress" {
  network_id  = netbird_network.tgsatan_egress.id
  peer_groups = [netbird_group.us_relay.id]
  masquerade  = true
  metric      = 9999
  enabled     = true
}

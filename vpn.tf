# This file is used to create a VPN tunnel between two regions eu to asia
resource "google_compute_vpn_tunnel" "eu-asia-gamingtunnel-1" {
  name          = "eu-asia-gamingtunnel-1"
  peer_ip       = google_compute_address.asia_static_ip.address
  shared_secret = data.google_secret_manager_secret_version.vpn_secret.secret_data
  target_vpn_gateway = google_compute_vpn_gateway.eu_gateway.id
  ike_version = 2

  #remo suggestions
  local_traffic_selector = ["192.68.40.0/24"]
  remote_traffic_selector = ["10.188.10.0/24"]

  #esp sets up pvt link
  #udp 500 and 4500 are for net translation
  depends_on = [
    google_compute_forwarding_rule.hq_fw_ruleesp,
    google_compute_forwarding_rule.hq_fw_ruleudp500,
    google_compute_forwarding_rule.hq_fw_udp4500,
  ]

}

resource "google_compute_vpn_gateway" "eu_gateway" {
  name    = "eu-gateway"
  network = google_compute_network.eu_gaming.id
}



resource "google_compute_address" "eu_static_ip" {
  name = "eu-static-ip"
}

#static ip for eu for asia
resource "google_compute_forwarding_rule" "hq_fw_ruleesp" {
  name        = "hq-fw-ruleesp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.eu_static_ip.address
  target      = google_compute_vpn_gateway.eu_gateway.id
}

resource "google_compute_forwarding_rule" "hq_fw_ruleudp500" {
  name        = "hq-fw-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.eu_static_ip.address
  target      = google_compute_vpn_gateway.eu_gateway.id
}

resource "google_compute_forwarding_rule" "hq_fw_udp4500" {
  name        = "hq-fw-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.eu_static_ip.address
  target      = google_compute_vpn_gateway.eu_gateway.id
}

resource "google_compute_route" "eu_asia_route" {
  name       = "eu-asia-route"
  network    = google_compute_network.asia_gaming.name
  dest_range = "192.68.40.0/24"
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.eu-asia-gamingtunnel-1.id
}

#VPN FROM ASIA TO EU

resource "google_compute_vpn_gateway" "asia_gateway" {
  name    = "asia-gateway"
  network = google_compute_network.asia_gaming.id
}

resource "google_compute_address" "asia_static_ip" {
  name = "asia-static-ip"
}

resource "google_compute_forwarding_rule" "asia_fr_esp" {
  name        = "asia-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.asia_static_ip.address
  target      = google_compute_vpn_gateway.asia_gateway.id
}

resource "google_compute_forwarding_rule" "asia_fr_udp500" {
  name        = "asia-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.asia_static_ip.address
  target      = google_compute_vpn_gateway.asia_gateway.id
}

resource "google_compute_forwarding_rule" "asia_fr_udp4500" {
  name        = "asia-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.asia_static_ip.address
  target      = google_compute_vpn_gateway.asia_gateway.id
}

resource "google_compute_vpn_tunnel" "asia_eu_gamingtunnel-1" {
  name          = "asia-eu-gamingtunnel-1"
  peer_ip       = google_compute_address.eu_static_ip.address
  shared_secret = data.google_secret_manager_secret_version.vpn_secret.secret_data

  target_vpn_gateway = google_compute_vpn_gateway.eu_gateway.id
  ike_version = 2
  local_traffic_selector = ["10.188.10.0/24"]
  remote_traffic_selector = ["192.68.40.0/24"]
  

  depends_on = [
    google_compute_forwarding_rule.asia_fr_esp,
    google_compute_forwarding_rule.asia_fr_udp500,
    google_compute_forwarding_rule.asia_fr_udp4500,
  ]
  
}

resource "google_compute_route" "asia_route" {
  name       = "asia-route"
  network    = google_compute_network.asia_gaming.name
  dest_range = "10.188.10.0/24"
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.asia_eu_gamingtunnel-1.id
}

data "google_secret_manager_secret_version" "vpn_secret" {
  secret  = "vpn-shared-secret"
  version = "latest"
}
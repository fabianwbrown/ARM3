#eu peering with us
resource "google_compute_network_peering" "peering1" {
  name         = "eu-peering1"
  network      = google_compute_network.eu_gaming.id
  peer_network = google_compute_network.us_gaming.id
}
#us peering with eu
resource "google_compute_network_peering" "peering2" {
  name         = "us-peering2"
  network      = google_compute_network.us_gaming.id
  peer_network = google_compute_network.eu_gaming.id
}


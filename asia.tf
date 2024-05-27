resource "google_compute_network" "asia_gaming" {
  project                 = "mentis-negotium"
  name                    = "asia-gaming-network-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_instance" "asia-game_vm" {
  name         = "asia-region-game"
  machine_type = "e2-micro"
  zone         = "asia-east1-a"
  
  tags = ["asia-http-server"]

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2019"

    }
  }

  network_interface {
    network = google_compute_network.asia_gaming.name
    subnetwork = google_compute_subnetwork.asia_subnet.id

    access_config {
      // Ephemeral IP
    }
  }
  
}

resource "google_compute_subnetwork" "asia_subnet" {
  name          = "asia-subnetwork"
  ip_cidr_range = "192.68.40.0/24"
  network       = google_compute_network.asia_gaming.id
  region        = "asia-east1"
  private_ip_google_access = true
}

resource "google_compute_firewall" "asia-allow-rdp" {
  name    = "allow-rdp"
  network = google_compute_network.asia_gaming.name
  

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["10.188.20.0/24", "10.188.10.0/24", "192.68.40.0/24"] #eu ip range 
  target_tags   = ["asia-http-server", "eu-http-server"]
  #remo suggestions
  #source_tags = ["0.0.0.0/0","]
  #target_tags = ["asia-rdp-server"]
}
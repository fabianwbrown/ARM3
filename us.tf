# #America virtual machines 1
resource "google_compute_network" "us_gaming" {
  project                 = "mentis-negotium"
  name                    = "us-gaming-network-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_instance" "us_game_vm1" {
  name         = "us-region-gamevm1"
  machine_type = "e2-micro"
  zone         = "us-east1-b"
  depends_on = [ google_compute_subnetwork.us_vm1_subnet ]
  
tags = ["us-http-server1","iap-ssh-allowed"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      
    }
  }

  network_interface {
    network = google_compute_network.us_gaming.name
    subnetwork = google_compute_subnetwork.us_vm1_subnet.name

    access_config {
      // Ephemeral IP
    }
  }
  metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }
}

#America virtual subnetwork 1
resource "google_compute_subnetwork" "us_vm1_subnet" {
  name          = "us1-subnetwork"
  ip_cidr_range = "172.18.40.0/24"
  network       = google_compute_network.us_gaming.id
  region        = "us-east1"
  private_ip_google_access = true
}

#America virtual firewall 1
resource "google_compute_firewall" "us_allow-http" {
  name    = "us-allow-http"
  network = google_compute_network.us_gaming.id

  allow {
    protocol = "tcp"
    ports    = ["80","22"]
  }

#   source_ranges = ["172.20.100.0/24","172.18.40.0/24","10.188.20.0/24","10.188.10.0/24"] #eu ip ranges
#   target_tags   = ["eu-http-server","eu-http-server2","us-http-server1","us-http-server"]

  #remo suggestions
  source_ranges = ["0.0.0.0/0", "35.235.240.0/20"] #GCPs cidr
  target_tags = ["us-http-server", "iap-ssh-allowed"]
  }
  

#America virtual machines 2
resource "google_compute_instance" "us_game_vm2" {
  name         = "us-region-gamevm2"
  machine_type = "e2-micro"
  zone         = "us-west1-a"
  
tags = ["us-http-server2"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      
    }
  }

  network_interface {
    network = google_compute_network.us_gaming.name
    subnetwork = google_compute_subnetwork.us_vm2_subnet.id

    access_config {
      // Ephemeral IP
    }
  }
  metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }
}

#America virtual subnetwork 2
resource "google_compute_subnetwork" "us_vm2_subnet" {
  name          = "us2-subnetwork"
  ip_cidr_range = "172.20.100.0/24"
  network       = google_compute_network.us_gaming.id
  region        = "us-west1" 
  private_ip_google_access = true
}


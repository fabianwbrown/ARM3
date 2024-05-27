resource "google_compute_network" "eu_gaming" {
  project                 = "mentis-negotium"
  name                    = "eu-gaming-network-vpc"
  auto_create_subnetworks = false
}

#EU HQ virtual machines 1
resource "google_compute_instance" "eurogame_vm1" {
  name         = "euro-game1"
  machine_type = "e2-micro"
  zone         = "europe-central2-b"
  
tags = ["eu-http-server1"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-11"
      
    }
  }

  network_interface {
    network = google_compute_network.eu_gaming.name
    subnetwork = google_compute_subnetwork.eu_gaming_subnet1.name

    access_config {
      // Ephemeral IP
    }
  }
  
  metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }


  # metadata = {
  #   startup-script = file("${path.module}/runscript.sh")
  # }
}
  
  


#EU HQ virtual subnetwork 1
resource "google_compute_subnetwork" "eu_gaming_subnet1" {
  name          = "eu-subnetwork"
  ip_cidr_range = "10.150.11.0/24"
  network       = google_compute_network.eu_gaming.id
  region        = "europe-central2"  
  private_ip_google_access = true    
}

#EU HQ virtual firewall 1
resource "google_compute_firewall" "allow-http" {
  name    = "eu-allow-http"
  network = google_compute_network.eu_gaming.name

  allow {
    protocol = "tcp"
    ports    = ["80","22"]
  }
  
  source_ranges = ["192.68.40.0/24","172.18.40.0/24","172.20.100.0/24","10.150.11.0/24","10.150.20.0/24"]
  target_tags   = ["eu-http-server1","eu-http-server2","us-http-server1","us-http-server","asia-http-server"]
}



#EU HQ virtual machines 2
resource "google_compute_instance" "eurogame_vm2" {
  name         = "euro-game2"
  machine_type = "e2-micro"
  zone         = "europe-central2-a"
  
  tags = ["eu-http-server2"]

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2019"
      
    }
  }

  network_interface {
    network = google_compute_network.eu_gaming.name
    subnetwork = google_compute_subnetwork.eu_gaming_subnet2.name


    access_config {
      // Ephemeral IP
    }
  }
  
 metadata_startup_script = file("${path.module}/runscript.sh")
}

#EU HQ virtual subnetwork 2
resource "google_compute_subnetwork" "eu_gaming_subnet2" {
  name          = "eu-subnetwork2"
  ip_cidr_range = "10.150.20.0/24"
  network       =  google_compute_network.eu_gaming.id
  region        = "europe-central2"
  private_ip_google_access = true
  
  }

#EU HQ virtual firewall 2
resource "google_compute_firewall" "eu-allow-rdp" {
  name    = "eu-allow-rdp"
  network = google_compute_network.eu_gaming.name
  
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  
   source_ranges = ["192.68.40.0/24","172.18.40.0/24","172.20.100.0/24","10.150.11.0/24","10.150.20.0/24"]
  target_tags   = ["eu-http-server1","eu-http-server2","us-http-server1","us-http-server","asia-http-server"]
  }
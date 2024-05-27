terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.30.0"
    }
  }
}


provider "google" {
  # Configuration options
  project     = "mentis-negotium"
  region      = "us-east1"
  zone        = "us-east1-c"
  credentials = "mentis-negotium-17998feda7af.json"
}


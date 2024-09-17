terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.41.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "terraform-gcp-366901"
  region = "us-central1"
  zone = "us-central1-a"
  credentials = "keys.json"
}
resource "google_compute_instance" "vm-from-tf" {
  name = "vm-from-tf"
  zone = "asia-southeast1-b"
  machine_type = "n1-standard-2"
  allow_stopping_for_update = true
  
  network_interface {
    network = "custom-vpc-tf"
    subnetwork = "sub-sg"
  }

  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-arm64-v20221102"
      size = 40
    }
    auto_delete = false
  }

  labels = {
    "env" = "tflearning"
  }
}
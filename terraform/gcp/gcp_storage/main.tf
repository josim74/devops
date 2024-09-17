resource "google_storage_bucket" "GCS0611" {
  name = "tf-course-bucket-from-terraform-ju0611"
  storage_class = "NEARLINE"
  location = "US-CENTRAL1"

  labels = {
    "env" = "tf_env"
    "dep" = "compilance"
  }

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 5
    }
    action {
      type = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  retention_policy {
    is_locked = true
    retention_period = 864000
  }
}

resource "google_storage_bucket_object" "picture" {
  name = "random_title"
  bucket = google_storage_bucket.GCS0611.name
  source = "josim.JPG"
}
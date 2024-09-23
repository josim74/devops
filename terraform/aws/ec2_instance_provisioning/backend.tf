terraform {
  backend "s3" {
    bucket = "terraform-state-74"
    key = "terraform/backend"
    region = "us-east-1"
  }
}
# Terraform block
terraform {
    required_version = "~> 1.3" # Which means any version equal & above 0.14 like 0.15, 0.16 and < 1.xx
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}

# Provider block
provider "aws" {
  region = "us-east-1"
}
# Input variables
# AWS region
variable "aws_region" {
  description = "Region in which aws resources to be created"
  type = string
  default = "us-east-1"
}

# AWS ec2 instance type
variable "instance_type" {
    description = "EC2 instance type"
    type = string
    default = "t2.micro"
}

# AWS EC2 instance key pair
variable "instance_keypair" {
  description = "AWS EC2 key pair that need to be associated with EC2 instance"
  type = string
  default = "tf_key"
}
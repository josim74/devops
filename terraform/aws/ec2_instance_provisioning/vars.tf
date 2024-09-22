variable "REGION" {
  default = "us-east-1"
}

variable "ZONE1" {
  default = "us-east-1a"
}

variable "AMIS" {
  type = map(any)
  default = {
    us-east-2 = "ami-037774efca2da0726"
    us-east-1 = "ami-0ebfd941bbafe70c6"
  }
}

variable "USER" {
  default = "ec2-user"
}
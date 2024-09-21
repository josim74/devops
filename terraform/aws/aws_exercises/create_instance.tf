provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "first_instance_tf" {
  ami                    = "ami-0ebfd941bbafe70c6"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = "first_instance_key_tf"
  vpc_security_group_ids = ["sg-038e2b9934ff7c3c9"]
  tags = {
    Name = "first_instance_tf"
  }
}
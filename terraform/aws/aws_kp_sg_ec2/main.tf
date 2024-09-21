provider "aws" {
  region = "us-east-1"
}

# Create a key pair
resource "aws_key_pair" "tf_ec2_key" {
  key_name   = "tf-ec2-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create a security group
resource "aws_security_group" "tf_ec2_sg" {
  name        = "tf-ec2-sg"
  description = "Allow SSH and HTTP inbound traffic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# User data script
data "template_file" "userdata" {
  template = file("userdata.sh")
}

# Create an EC2 instance
resource "aws_instance" "tf_ec2_instance" {
  ami           = "ami-0a0e5d9c7acc336f1"  # Update with your desired AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.tf_ec2_key.key_name
  security_groups = [aws_security_group.tf_ec2_sg.name]
  
  user_data = data.template_file.userdata.rendered

  tags = {
    Name = "tf-ec2-instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}
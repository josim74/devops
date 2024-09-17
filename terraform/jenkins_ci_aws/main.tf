provider "aws" {
  region = "us-east-1"
}

# Create a key pair
resource "aws_key_pair" "tf_vprofile_ci_key" {
  key_name   = "tf-vprofile-ci-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create a security group
resource "aws_security_group" "tf_jenkins_sg" {
  name        = "tf-jenkins-sg"
  description = "Allow SSH and HTTP inbound traffic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
resource "aws_security_group" "tf_nexus_sg" {
  name        = "tf-nexus-sg"
  description = "Allow SSH and HTTP inbound traffic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    security_groups  = [aws_security_group.tf_jenkins_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "tf_sonar_sg" {
  name        = "tf-sonar-sg"
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
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups  = [aws_security_group.tf_jenkins_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# User data script
data "template_file" "jenkins_userdata" {
  template = file("jenkins_userdata.sh")
}
data "template_file" "sonar_userdata" {
  template = file("sonar_userdata.sh")
}
data "template_file" "nexus_userdata" {
  template = file("nexus_userdata.sh")
}

# Create an EC2 instances
resource "aws_instance" "tf_jenkins_instance" {
  ami           = "ami-0a0e5d9c7acc336f1"  # Update with your desired AMI ID
  instance_type = "t2.small"
  key_name      = aws_key_pair.tf_vprofile_ci_key.key_name
  security_groups = [aws_security_group.tf_jenkins_sg.name]
  
  user_data = data.template_file.jenkins_userdata.rendered

  tags = {
    Name = "tf-jenkins-instance"
  }
}
resource "aws_instance" "tf_sonar_instance" {
  ami           = "ami-0a0e5d9c7acc336f1"  # Update with your desired AMI ID
  instance_type = "t2.medium"
  key_name      = aws_key_pair.tf_vprofile_ci_key.key_name
  security_groups = [aws_security_group.tf_sonar_sg.name]
  
  user_data = data.template_file.sonar_userdata.rendered

  tags = {
    Name = "tf-sonar-instance"
  }
}
resource "aws_instance" "tf_nexus_instance" {
  ami           = "ami-0df2a11dd1fe1f8e3"  # Update with your desired AMI ID
  instance_type = "t2.medium"
  key_name      = aws_key_pair.tf_vprofile_ci_key.key_name
  security_groups = [aws_security_group.tf_nexus_sg.name]
  
  user_data = data.template_file.nexus_userdata.rendered

  tags = {
    Name = "tf-nexus-instance"
  }
}

output "jenkins_instance_public_ip" {
  value = aws_instance.tf_jenkins_instance.public_ip
}
output "sonar_instance_public_ip" {
  value = aws_instance.tf_sonar_instance.public_ip
}
output "nexus_instance_public_ip" {
  value = aws_instance.tf_nexus_instance.public_ip
}
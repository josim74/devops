resource "aws_key_pair" "tf-instance-pub-key" {
  key_name   = "tf-pub-key"
  public_key = file("tf_pub_key.pub")
}
resource "aws_instance" "tf-instance" {
  ami                    = var.AMIS[var.REGION]
  instance_type          = "t2.micro"
  availability_zone      = var.ZONE1
  key_name               = aws_key_pair.tf-instance-pub-key.key_name
  vpc_security_group_ids = ["sg-038e2b9934ff7c3c9"]
  tags = {
    Name    = "tf-instance"
    Project = "Terraform"
  }
  provisioner "file" {
    source      = "provision.sh"
    destination = "/tmp/provision.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/provision.sh",
      "sudo /tmp/provision.sh"
    ]
  }
  connection {
    user        = var.USER
    private_key = file("tf_pub_key")
    host        = self.public_ip
  }
}
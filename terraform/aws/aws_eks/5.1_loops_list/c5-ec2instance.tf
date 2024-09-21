# EC2 instance
resource "aws_instance" "tf_ec2" {
    ami = data.aws_ami.amz_linux2.id
    # instance_type = var.instance_type
    # instance_type = var.instance_type_list[1] # for list
    instance_type = var.instance_type_map["prod"] # for map
    user_data = file("${path.module}/app1-install.sh")
    key_name = var.instance_keypair
    vpc_security_group_ids = [ aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id ]
    count = 2
    tags = {
        "Name" = "EC2 Demo-${count.index}"
    }
  
}
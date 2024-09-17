# EC2 instance
resource "aws_instance" "tf_ec2" {
    ami = data.aws_ami.amz_linux2.id
    # instance_type = var.instance_type
    # instance_type = var.instance_type_list[1] # for list
    instance_type = var.instance_type_map["prod"] # for map
    user_data = file("${path.module}/app1-install.sh")
    key_name = var.instance_keypair
    vpc_security_group_ids = [ aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id ]
    # Create EC2 instance in all availability zones of a VPC
    for_each = toset(keys({for az, details in data.aws_ec2_instance_type_offerings.my_ins_type3: az => details.instance_types if length(details.instance_types) != 0 }))
    availability_zone = each.key # You can also use each.value because for list items each.key == each.value
    tags = {
        "Name" = "for-each-demo-${each.value}"
    }
  
}
# Terraform Output Values
# output "instance_publicip" {
#   description = "EC2 Instance Public IP"
#   value = aws_instance.tf_ec2[count.index].public_ip
# }

# output "instance_publicdns" {
#   description = "EC2 Instance Public DNS"
#   value = aws_instance.tf_ec2[count.inded].public_dns
# }

# Output - for loop with list
output "for_output_list" {
  description = "For loop with list"
  value = [for instance in aws_instance.tf_ec2: instance.public_dns]
}

# Output - for loop with map
output "for_output_map1" {
  description = "For loop with list"
  value = {for instance in aws_instance.tf_ec2: instance.id => instance.public_dns}
}

# Output - for loop with map (advanced)
output "for_output_map2" {
  description = "For loop with list"
  value = {for c, instance in aws_instance.tf_ec2: c => instance.public_dns}
}

# Ouptput legecy Splat Operator - returns the list (only work with count)
output "legecy_splat_instance_publicdns" {
  description = "Legecy Splat expression"
  value = aws_instance.tf_ec2.*.public_dns
}

# Ouptput latest Splat Operator - returns the list (only work with count)
output "latest_splat_instance_publicdns" {
  description = "Legecy Splat expression"
  value = aws_instance.tf_ec2[*].public_dns
}
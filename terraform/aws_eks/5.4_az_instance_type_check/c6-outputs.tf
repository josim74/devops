# Terraform Output Values

# Output - EC2 instance public IP with toset function
output "instance_public_ip" {
  description = "Public IP"
  value = [for instance in aws_instance.tf_ec2: instance.public_ip]
}

# Output - EC2 instance public DNS aws with toset function
output "instance_public_dns" {
  description = "Public DNS"
  value = [for instance in aws_instance.tf_ec2: instance.public_dns]
}

#Output - EC2 instance public DNS with tomap function
output "instance_public_dns2" {
  description = "Public DNS"
  value = {for az, instance in aws_instance.tf_ec2: az => instance.public_dns}
}
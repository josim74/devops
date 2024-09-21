# Datasource-1
# Availability zones datasource
data "aws_availability_zones" "my_azones" {
  filter {
    name = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Datasource-2
data "aws_ec2_instance_type_offerings" "my_ins_type3" {
  for_each = toset(data.aws_availability_zones.my_azones.names)
  filter {
    name   = "instance-type"
    values = ["t3.micro"]
  }

  filter {
    name   = "location"
    values = [each.value]
  }

  location_type = "availability-zone"
}

# Output1
# Important note: Once for_each is set, it's attributes must be accessed on specific instances
output "output_v3_1" {
#   value = data.aws_ec2_instance_type_offerings.my_ins_type1.instance_types
  value = {for az, details in data.aws_ec2_instance_type_offerings.my_ins_type3: az =>details.instance_types}
}

# Output2
output "output_v3_2" {
#   value = data.aws_ec2_instance_type_offerings.my_ins_type1.instance_types
  value = {for az, details in data.aws_ec2_instance_type_offerings.my_ins_type3:
  az => details.instance_types if length(details.instance_types) != 0 }
}
# Output3
output "output_v3_3" {
#   value = data.aws_ec2_instance_type_offerings.my_ins_type1.instance_types
  value = keys({for az, details in data.aws_ec2_instance_type_offerings.my_ins_type3:
  az => details.instance_types if length(details.instance_types) != 0 })
}
# Output4
output "output_v3_4" {
#   value = data.aws_ec2_instance_type_offerings.my_ins_type1.instance_types
  value = keys({for az, details in data.aws_ec2_instance_type_offerings.my_ins_type3:
  az => details.instance_types if length(details.instance_types) != 0 })[0]
}
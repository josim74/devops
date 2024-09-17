# Datasource
data "aws_ec2_instance_type_offerings" "my_ins_type2" {
  for_each = toset(["us-east-1a", "us-east-1b", "us-east-1e"])
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
output "output_v2_1" {
#   value = data.aws_ec2_instance_type_offerings.my_ins_type1.instance_types
  value = [for t in data.aws_ec2_instance_type_offerings.my_ins_type2: t.instance_types]
}

output "output_v2_2" {
#   value = data.aws_ec2_instance_type_offerings.my_ins_type1.instance_types
  value = {for az, details in data.aws_ec2_instance_type_offerings.my_ins_type2: az =>details.instance_types}
}
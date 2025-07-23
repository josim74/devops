```
# AWS CLI version
aws --version

# List all s3 buckets
aws s3 ls

# Create an s3 bucket (name must be globally unique)
aws s3 mb s3://my-bucket-ju-25

# Upload file to the s3 bucket
aws s3 cp ./file_name.txt s3://my-bucket-ju-25

# list s3 bucket content
aws s3 ls s3://my-bucket-ju-25

# Delete s3 bucket (the becket must be empty otherwise use --force for force delete)
aws s3 rb s3://my-bucket-ju-25 --force

```
## EC2
```
# List EC2 instances
aws ec2 describe-instances

# Find the instance id
aws ec2 describe-instances | grep InstanceId

# Start ec2 instance
aws ec2 start-instances --instance-ids i-061f35fc0c9eeabf4

# Stop ec2 instance
aws ec2 stop-instances --instance-ids i-061f35fc0c9eeabf4
```
## IAM
```
# Create iam user
aws iam create-user --user-name aws-admin

# List all iam users
aws iam list-users

# Delete ima user
aws iam delete-user --user-name aws-admin
```
## SNS
```
# Create SNS topic
aws sns create-topic --name my-sns-topic

# List SNS topics
aws sns list-topics

# Delete SNS topic
aws sns delete-topic --topic-arn arn:aws:sns:us-east-1:688567273714:my-sns-topic
```

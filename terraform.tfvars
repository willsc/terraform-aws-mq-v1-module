# Copy this file to terraform.tfvars and set your password
# cp terraform.tfvars.example terraform.tfvars

# Required
mq_password = "YourSecurePassword123!"

# Optional
aws_region         = "eu-west-1"
environment        = "dev"
project            = "mq-cluster"
vpc_cidr_block     = "10.0.0.0/16"
host_instance_type = "mq.m5.large"
mq_username        = "mqadmin"
organization       = "My Organization"

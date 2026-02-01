#------------------------------------------------------------------------------
# Example: Multi-AZ MQ Cluster with Auto-Created VPC
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#------------------------------------------------------------------------------
# MQ Module - Fully Automatic VPC and Subnet Creation
#------------------------------------------------------------------------------

module "mq" {
  source = "./modules/amq"

  broker_name     = "${var.environment}-mq-broker"
  deployment_mode = "ACTIVE_STANDBY_MULTI_AZ"
  engine_type     = "ActiveMQ"
  engine_version  = "5.18"

  # Instance
  host_instance_type = var.host_instance_type
  storage_type       = "efs"

  # VPC - Will be auto-created since we don't provide vpc_id or subnet_ids
  vpc_cidr_block = var.vpc_cidr_block
  number_of_azs  = 3

  # NLB with self-signed certificate
  nlb_enabled             = true
  create_self_signed_cert = true
  cert_common_name        = "${var.environment}-mq.internal"
  cert_organization       = var.organization

  nlb_listeners = {
    openwire = {
      port     = 61617
      protocol = "TLS"
    }
    mqtt = {
      port     = 8883
      protocol = "TLS"
    }
  }

  # Security
  create_security_group = true
  allowed_cidr_blocks   = [var.vpc_cidr_block]

  # Credentials
  username = var.mq_username
  password = var.mq_password

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

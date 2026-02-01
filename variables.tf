variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "mq-cluster"
}

variable "vpc_cidr_block" {
  description = "CIDR block for auto-created VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "host_instance_type" {
  description = "MQ broker instance type"
  type        = string
  default     = "mq.m5.large"
}

variable "mq_username" {
  description = "MQ admin username"
  type        = string
  default     = "mqadmin"
}

variable "mq_password" {
  description = "MQ admin password (min 12 characters)"
  type        = string
  sensitive   = true
}

variable "organization" {
  description = "Organization name for certificate"
  type        = string
  default     = "My Organization"
}

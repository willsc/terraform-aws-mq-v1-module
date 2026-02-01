variable "broker_name" {
  type        = string
  description = "Name of the broker"
}

#------------------------------------------------------------------------------
# VPC Variables
#------------------------------------------------------------------------------

variable "vpc_id" {
  type        = string
  description = "VPC ID where the broker will be deployed. If not provided and subnet_ids is empty, a new VPC will be created."
  default     = null
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of VPC subnet IDs. If not provided, subnets will be created automatically."
  default     = []
}

variable "number_of_azs" {
  type        = number
  description = "Number of availability zones to use (1-6). Defaults to 1 for SINGLE_INSTANCE, 3 for multi-AZ."
  default     = null
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for subnets. Auto-calculated if not provided."
  default     = null
}

variable "subnet_newbits" {
  type        = number
  description = "Number of bits to add to VPC CIDR for subnet calculation"
  default     = 8
}

variable "subnet_netnum_offset" {
  type        = number
  description = "Starting offset for subnet numbering"
  default     = 0
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

#------------------------------------------------------------------------------
# Broker Variables
#------------------------------------------------------------------------------

variable "deployment_mode" {
  type        = string
  description = "Deployment mode: SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, or CLUSTER_MULTI_AZ"
  default     = "ACTIVE_STANDBY_MULTI_AZ"

  validation {
    condition     = contains(["SINGLE_INSTANCE", "ACTIVE_STANDBY_MULTI_AZ", "CLUSTER_MULTI_AZ"], var.deployment_mode)
    error_message = "Valid values: SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, CLUSTER_MULTI_AZ."
  }
}

variable "engine_type" {
  type        = string
  description = "Type of broker engine: ActiveMQ or RabbitMQ"
  default     = "ActiveMQ"

  validation {
    condition     = contains(["ActiveMQ", "RabbitMQ"], var.engine_type)
    error_message = "Valid values: ActiveMQ, RabbitMQ."
  }
}

variable "engine_version" {
  type        = string
  description = "Version of the broker engine"
  default     = "5.18"
}

variable "host_instance_type" {
  type        = string
  description = "Broker instance type"
  default     = "mq.m5.large"
}

variable "storage_type" {
  type        = string
  description = "Storage type: efs or ebs"
  default     = "efs"
}

variable "username" {
  type        = string
  description = "Admin username for the broker"
  default     = "admin"
}

variable "password" {
  type        = string
  description = "Admin password for the broker"
  sensitive   = true
}

variable "publicly_accessible" {
  type        = bool
  description = "Whether the broker is publicly accessible"
  default     = false
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Enable automatic minor version upgrades"
  default     = true 
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately"
  default     = false
}

variable "maintenance_day_of_week" {
  type        = string
  description = "Day of week for maintenance window"
  default     = "SUNDAY"
}

variable "maintenance_time_of_day" {
  type        = string
  description = "Time of day for maintenance window (HH:MM format)"
  default     = "03:00"
}

variable "maintenance_time_zone" {
  type        = string
  description = "Time zone for maintenance window"
  default     = "UTC"
}

#------------------------------------------------------------------------------
# Security Group Variables
#------------------------------------------------------------------------------

variable "create_security_group" {
  type        = bool
  description = "Create a security group for the broker"
  default     = true
}

variable "security_group_name" {
  type        = string
  description = "Name for the security group"
  default     = null
}

variable "security_groups" {
  type        = list(string)
  description = "List of existing security group IDs"
  default     = []
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to access the broker"
  default     = []
}

#------------------------------------------------------------------------------
# NLB Variables
#------------------------------------------------------------------------------

variable "nlb_enabled" {
  type        = bool
  description = "Create a Network Load Balancer"
  default     = false
}

variable "nlb_internal" {
  type        = bool
  description = "Whether the NLB is internal"
  default     = true
}

variable "nlb_listeners" {
  type = map(object({
    port        = number
    protocol    = string
    target_port = optional(number)
    ssl_policy  = optional(string)
  }))
  description = "Map of NLB listener configurations"
  default = {
    openwire = {
      port     = 61617
      protocol = "TLS"
    }
  }
}

#------------------------------------------------------------------------------
# Certificate Variables
#------------------------------------------------------------------------------

variable "create_self_signed_cert" {
  type        = bool
  description = "Create a self-signed certificate"
  default     = false
}

variable "create_acm_certificate" {
  type        = bool
  description = "Request an ACM certificate"
  default     = false
}

variable "nlb_certificate_arn" {
  type        = string
  description = "Existing certificate ARN for NLB"
  default     = null
}

variable "cert_domain_name" {
  type        = string
  description = "Domain name for the certificate"
  default     = null
}

variable "cert_common_name" {
  type        = string
  description = "Common name for self-signed certificate"
  default     = null
}

variable "cert_organization" {
  type        = string
  description = "Organization for the certificate"
  default     = "Amazon MQ"
}

variable "cert_validity_period_hours" {
  type        = number
  description = "Validity period in hours for self-signed cert"
  default     = 8760
}

variable "cert_subject_alternative_names" {
  type        = list(string)
  description = "Subject alternative names for ACM certificate"
  default     = []
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 zone ID for DNS validation"
  default     = null
}

variable "create_route53_validation_records" {
  type        = bool
  description = "Create Route53 validation records"
  default     = true
}

variable "wait_for_certificate_validation" {
  type        = bool
  description = "Wait for certificate validation"
  default     = true
}

variable "cert_validation_method" {
  type        = string
  description = "Certificate validation method: DNS or EMAIL"
  default     = "DNS"
}

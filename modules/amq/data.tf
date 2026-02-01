#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_subnet" "provided" {
  count = length(var.subnet_ids) > 0 ? length(var.subnet_ids) : 0
  id    = var.subnet_ids[count.index]
}

#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------

locals {
  # Number of AZs
  az_count = var.number_of_azs != null ? var.number_of_azs : (
    var.deployment_mode == "SINGLE_INSTANCE" ? 1 : 3
  )

  # Available AZs
  available_azs = slice(
    data.aws_availability_zones.available.names,
    0,
    min(local.az_count, length(data.aws_availability_zones.available.names))
  )

  # Create VPC if no vpc_id and no subnet_ids provided
  create_vpc = var.vpc_id == null && length(var.subnet_ids) == 0

  # Create subnets if no subnet_ids provided
  create_subnets = length(var.subnet_ids) == 0

  # VPC ID to use
  vpc_id = coalesce(
    var.vpc_id,
    length(var.subnet_ids) > 0 ? data.aws_subnet.provided[0].vpc_id : null,
    local.create_vpc ? aws_vpc.main[0].id : null
  )

  # Subnet CIDRs
  subnet_cidrs = var.subnet_cidrs != null ? var.subnet_cidrs : [
    for i in range(local.az_count) : cidrsubnet(var.vpc_cidr_block, var.subnet_newbits, i + var.subnet_netnum_offset)
  ]

  # Final subnet IDs
  subnet_ids = local.create_subnets ? aws_subnet.main[*].id : var.subnet_ids

  # Subnet to AZ mapping
  subnet_az_map = local.create_subnets ? {
    for idx, subnet in aws_subnet.main : subnet.id => subnet.availability_zone
  } : {
    for idx, subnet in data.aws_subnet.provided : subnet.id => subnet.availability_zone
  }

  # Unique AZs
  unique_azs = local.create_subnets ? local.available_azs : distinct([
    for subnet in data.aws_subnet.provided : subnet.availability_zone
  ])

  # Multi-AZ check
  is_multi_az = contains(["ACTIVE_STANDBY_MULTI_AZ", "CLUSTER_MULTI_AZ"], var.deployment_mode)

  # Broker subnet count
  broker_subnet_count = var.deployment_mode == "SINGLE_INSTANCE" ? 1 : (
    var.deployment_mode == "ACTIVE_STANDBY_MULTI_AZ" ? 2 : local.az_count
  )

  # Broker subnet IDs
  broker_subnet_ids = slice(local.subnet_ids, 0, min(local.broker_subnet_count, length(local.subnet_ids)))
}

#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  count = local.create_vpc ? 1 : 0

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.broker_name}-vpc"
  })
}

#------------------------------------------------------------------------------
# Subnets
#------------------------------------------------------------------------------

resource "aws_subnet" "main" {
  count = local.create_subnets ? local.az_count : 0

  vpc_id            = local.vpc_id
  cidr_block        = local.subnet_cidrs[count.index]
  availability_zone = local.available_azs[count.index]

  tags = merge(var.tags, {
    Name = "${var.broker_name}-subnet-${local.available_azs[count.index]}"
  })

  depends_on = [aws_vpc.main]
}

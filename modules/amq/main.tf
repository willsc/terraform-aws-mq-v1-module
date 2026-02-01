#------------------------------------------------------------------------------
# Amazon MQ Broker
#------------------------------------------------------------------------------

resource "aws_mq_broker" "main" {
  broker_name = var.broker_name

  engine_type         = var.engine_type
  engine_version      = var.engine_version
  host_instance_type  = var.host_instance_type
  deployment_mode     = var.deployment_mode
  storage_type        = var.storage_type
  publicly_accessible = var.publicly_accessible

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  subnet_ids         = local.broker_subnet_ids
  security_groups    = local.security_group_ids

  user {
    username = var.username
    password = var.password
  }

  maintenance_window_start_time {
    day_of_week = var.maintenance_day_of_week
    time_of_day = var.maintenance_time_of_day
    time_zone   = var.maintenance_time_zone
  }

  logs {
    general = true
    audit   = var.engine_type == "ActiveMQ" ? true : null
  }

  tags = merge(var.tags, {
    Name = var.broker_name
  })

  depends_on = [
    aws_subnet.main,
    aws_security_group.main
  ]
}

#------------------------------------------------------------------------------
# Security Group
#------------------------------------------------------------------------------

locals {
  security_group_ids = var.create_security_group ? [aws_security_group.main[0].id] : var.security_groups
}

resource "aws_security_group" "main" {
  count = var.create_security_group ? 1 : 0

  name        = var.security_group_name != null ? var.security_group_name : "${var.broker_name}-sg"
  description = "Security group for ${var.broker_name} MQ broker"
  vpc_id      = local.vpc_id

  # OpenWire
  ingress {
    from_port   = 61617
    to_port     = 61617
    protocol    = "tcp"
    cidr_blocks = length(var.allowed_cidr_blocks) > 0 ? var.allowed_cidr_blocks : [var.vpc_cidr_block]
    description = "OpenWire"
  }

  # AMQP
  ingress {
    from_port   = 5671
    to_port     = 5671
    protocol    = "tcp"
    cidr_blocks = length(var.allowed_cidr_blocks) > 0 ? var.allowed_cidr_blocks : [var.vpc_cidr_block]
    description = "AMQP"
  }

  # MQTT
  ingress {
    from_port   = 8883
    to_port     = 8883
    protocol    = "tcp"
    cidr_blocks = length(var.allowed_cidr_blocks) > 0 ? var.allowed_cidr_blocks : [var.vpc_cidr_block]
    description = "MQTT"
  }

  # STOMP
  ingress {
    from_port   = 61614
    to_port     = 61614
    protocol    = "tcp"
    cidr_blocks = length(var.allowed_cidr_blocks) > 0 ? var.allowed_cidr_blocks : [var.vpc_cidr_block]
    description = "STOMP"
  }

  # Web Console
  ingress {
    from_port   = 8162
    to_port     = 8162
    protocol    = "tcp"
    cidr_blocks = length(var.allowed_cidr_blocks) > 0 ? var.allowed_cidr_blocks : [var.vpc_cidr_block]
    description = "Web Console"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(var.tags, {
    Name = var.security_group_name != null ? var.security_group_name : "${var.broker_name}-sg"
  })

  depends_on = [aws_vpc.main]
}

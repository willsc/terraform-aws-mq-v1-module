#------------------------------------------------------------------------------
# Network Load Balancer
#------------------------------------------------------------------------------

resource "aws_lb" "main" {
  count = var.nlb_enabled ? 1 : 0

  name               = "${var.broker_name}-nlb"
  internal           = var.nlb_internal
  load_balancer_type = "network"
  subnets            = local.subnet_ids

  enable_cross_zone_load_balancing = true

  tags = merge(var.tags, {
    Name = "${var.broker_name}-nlb"
  })

  depends_on = [aws_subnet.main]
}

#------------------------------------------------------------------------------
# Target Groups
#------------------------------------------------------------------------------

resource "aws_lb_target_group" "main" {
  for_each = var.nlb_enabled ? var.nlb_listeners : {}

  name        = "${var.broker_name}-${each.key}"
  port        = coalesce(each.value.target_port, each.value.port)
  protocol    = "TCP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = coalesce(each.value.target_port, each.value.port)
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = merge(var.tags, {
    Name = "${var.broker_name}-${each.key}"
  })

  depends_on = [aws_vpc.main]
}

#------------------------------------------------------------------------------
# Listeners
#------------------------------------------------------------------------------

resource "aws_lb_listener" "main" {
  for_each = var.nlb_enabled ? var.nlb_listeners : {}

  load_balancer_arn = aws_lb.main[0].arn
  port              = each.value.port
  protocol          = each.value.protocol

  ssl_policy      = each.value.protocol == "TLS" ? coalesce(each.value.ssl_policy, "ELBSecurityPolicy-TLS13-1-2-2021-06") : null
  certificate_arn = each.value.protocol == "TLS" ? local.certificate_arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.key].arn
  }

  depends_on = [
    aws_lb.main,
    aws_lb_target_group.main,
    aws_acm_certificate.self_signed,
    aws_acm_certificate.acm_issued
  ]
}

#------------------------------------------------------------------------------
# Target Group Attachments
# Using null_resource with local-exec to register targets after broker creation
#------------------------------------------------------------------------------

locals {
  listener_keys = var.nlb_enabled ? keys(var.nlb_listeners) : []
  
  # Number of instances based on deployment mode
  instance_count = var.deployment_mode == "SINGLE_INSTANCE" ? 1 : 2
}

# We need to register each broker instance to each target group
# Using count with a flattened index approach

resource "aws_lb_target_group_attachment" "instance_0" {
  for_each = var.nlb_enabled ? var.nlb_listeners : {}

  target_group_arn = aws_lb_target_group.main[each.key].arn
  target_id        = aws_mq_broker.main.instances[0].ip_address
  port             = coalesce(each.value.target_port, each.value.port)

  depends_on = [aws_mq_broker.main]
}

# Second instance (only for multi-AZ deployments)
resource "aws_lb_target_group_attachment" "instance_1" {
  for_each = var.nlb_enabled && local.is_multi_az ? var.nlb_listeners : {}

  target_group_arn = aws_lb_target_group.main[each.key].arn
  target_id        = aws_mq_broker.main.instances[1].ip_address
  port             = coalesce(each.value.target_port, each.value.port)

  depends_on = [aws_mq_broker.main]
}

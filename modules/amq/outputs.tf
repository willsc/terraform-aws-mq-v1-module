#------------------------------------------------------------------------------
# Broker Outputs
#------------------------------------------------------------------------------

output "broker_id" {
  value       = aws_mq_broker.main.id
  description = "MQ broker ID"
}

output "broker_arn" {
  value       = aws_mq_broker.main.arn
  description = "MQ broker ARN"
}

output "broker_instances" {
  value       = aws_mq_broker.main.instances
  description = "MQ broker instances"
}

output "broker_endpoints" {
  value       = flatten(aws_mq_broker.main.instances[*].endpoints)
  description = "Broker endpoints"
}

output "broker_console_url" {
  value       = try(aws_mq_broker.main.instances[0].console_url, "")
  description = "Web console URL"
}

#------------------------------------------------------------------------------
# Network Outputs
#------------------------------------------------------------------------------

output "vpc_id" {
  value       = local.vpc_id
  description = "VPC ID"
}

output "subnet_ids" {
  value       = local.subnet_ids
  description = "Subnet IDs"
}

output "availability_zones" {
  value       = local.unique_azs
  description = "Availability zones"
}

output "security_group_id" {
  value       = try(aws_security_group.main[0].id, "")
  description = "Security group ID"
}

#------------------------------------------------------------------------------
# NLB Outputs
#------------------------------------------------------------------------------

output "nlb_arn" {
  value       = try(aws_lb.main[0].arn, "")
  description = "NLB ARN"
}

output "nlb_dns_name" {
  value       = try(aws_lb.main[0].dns_name, "")
  description = "NLB DNS name"
}

output "nlb_zone_id" {
  value       = try(aws_lb.main[0].zone_id, "")
  description = "NLB zone ID"
}

#------------------------------------------------------------------------------
# Certificate Outputs
#------------------------------------------------------------------------------

output "certificate_arn" {
  value       = local.certificate_arn
  description = "Certificate ARN"
}

output "certificate_type" {
  value = local.create_self_signed ? "self-signed" : (
    local.create_acm_cert ? "acm-issued" : "existing"
  )
  description = "Certificate type"
}

output "self_signed_cert_pem" {
  value       = try(tls_self_signed_cert.main[0].cert_pem, "")
  description = "Self-signed certificate PEM"
  sensitive   = true
}

output "certificate_validation_records" {
  value = local.create_acm_cert && var.cert_validation_method == "DNS" ? [
    for dvo in aws_acm_certificate.acm_issued[0].domain_validation_options : {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  ] : []
  description = "DNS validation records for ACM certificate"
}

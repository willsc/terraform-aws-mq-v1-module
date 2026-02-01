output "broker_id" {
  description = "MQ broker ID"
  value       = module.mq.broker_id
}

output "broker_arn" {
  description = "MQ broker ARN"
  value       = module.mq.broker_arn
}

output "broker_endpoints" {
  description = "Broker endpoints"
  value       = module.mq.broker_endpoints
}

output "broker_console_url" {
  description = "Web console URL"
  value       = module.mq.broker_console_url
}

output "vpc_id" {
  description = "VPC ID (auto-created)"
  value       = module.mq.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs (auto-created)"
  value       = module.mq.subnet_ids
}

output "availability_zones" {
  description = "Availability zones"
  value       = module.mq.availability_zones
}

output "nlb_dns_name" {
  description = "NLB DNS name - use this to connect"
  value       = module.mq.nlb_dns_name
}

output "certificate_arn" {
  description = "Certificate ARN"
  value       = module.mq.certificate_arn
}

output "certificate_type" {
  description = "Certificate type"
  value       = module.mq.certificate_type
}

output "self_signed_cert_pem" {
  description = "Self-signed certificate PEM (add to client trust store)"
  value       = module.mq.self_signed_cert_pem
  sensitive   = true
}

output "connection_info" {
  description = "Connection information"
  value = {
    nlb_endpoint  = module.mq.nlb_dns_name
    openwire_port = 61617
    mqtt_port     = 8883
    username      = var.mq_username
  }
}

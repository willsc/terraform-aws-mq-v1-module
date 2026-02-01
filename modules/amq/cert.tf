#------------------------------------------------------------------------------
# Certificate Configuration
#------------------------------------------------------------------------------

locals {
  create_self_signed = var.nlb_enabled && var.create_self_signed_cert
  create_acm_cert    = var.nlb_enabled && var.create_acm_certificate && !var.create_self_signed_cert

  cert_domain = coalesce(var.cert_domain_name, var.cert_common_name, "${var.broker_name}.local")

  create_dns_validation = (
    local.create_acm_cert &&
    var.cert_validation_method == "DNS" &&
    var.route53_zone_id != null &&
    var.create_route53_validation_records
  )

  wait_for_validation = (
    local.create_dns_validation &&
    var.wait_for_certificate_validation
  )

  certificate_arn = coalesce(
    local.create_self_signed ? try(aws_acm_certificate.self_signed[0].arn, null) : null,
    local.wait_for_validation ? try(aws_acm_certificate_validation.main[0].certificate_arn, null) : null,
    local.create_acm_cert ? try(aws_acm_certificate.acm_issued[0].arn, null) : null,
    var.nlb_certificate_arn
  )
}

#------------------------------------------------------------------------------
# Self-Signed Certificate
#------------------------------------------------------------------------------

resource "tls_private_key" "main" {
  count     = local.create_self_signed ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "main" {
  count = local.create_self_signed ? 1 : 0

  private_key_pem = tls_private_key.main[0].private_key_pem

  subject {
    common_name  = local.cert_domain
    organization = var.cert_organization
  }

  validity_period_hours = var.cert_validity_period_hours

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [local.cert_domain]
}

resource "aws_acm_certificate" "self_signed" {
  count = local.create_self_signed ? 1 : 0

  private_key      = tls_private_key.main[0].private_key_pem
  certificate_body = tls_self_signed_cert.main[0].cert_pem

  tags = merge(var.tags, {
    Name = "${var.broker_name}-cert"
    Type = "self-signed"
  })

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# ACM Certificate
#------------------------------------------------------------------------------

resource "aws_acm_certificate" "acm_issued" {
  count = local.create_acm_cert ? 1 : 0

  domain_name               = local.cert_domain
  subject_alternative_names = var.cert_subject_alternative_names
  validation_method         = var.cert_validation_method

  tags = merge(var.tags, {
    Name = "${var.broker_name}-cert"
    Type = "acm-issued"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = local.create_dns_validation ? {
    for dvo in aws_acm_certificate.acm_issued[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

resource "aws_acm_certificate_validation" "main" {
  count = local.wait_for_validation ? 1 : 0

  certificate_arn         = aws_acm_certificate.acm_issued[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

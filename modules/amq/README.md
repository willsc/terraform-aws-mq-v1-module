# terraform-aws-mq

Terraform module for Amazon MQ with automatic VPC/subnet creation, multi-AZ support, and NLB.

## Features

- **Automatic VPC Creation** - No existing infrastructure required
- **Multi-AZ Support** - Up to 3 availability zones
- **Self-Signed Certificates** - No DNS required
- **Network Load Balancer** - TLS termination

## Quick Start

```hcl
module "mq" {
  source = "path/to/module"

  broker_name = "my-broker"
  password    = "YourSecurePassword123!"

  # Everything else is auto-created!
}
```

## Usage with NLB

```hcl
module "mq" {
  source = "path/to/module"

  broker_name     = "my-broker"
  deployment_mode = "ACTIVE_STANDBY_MULTI_AZ"

  # Auto-create VPC in 3 AZs
  vpc_cidr_block = "10.0.0.0/16"
  number_of_azs  = 3

  # NLB with self-signed cert
  nlb_enabled             = true
  create_self_signed_cert = true

  nlb_listeners = {
    openwire = { port = 61617, protocol = "TLS" }
    mqtt     = { port = 8883, protocol = "TLS" }
  }

  username = "admin"
  password = var.mq_password
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| broker_name | Name of the broker | string | - | yes |
| password | Admin password | string | - | yes |
| vpc_id | Existing VPC ID | string | null | no |
| subnet_ids | Existing subnet IDs | list(string) | [] | no |
| vpc_cidr_block | CIDR for auto-created VPC | string | "10.0.0.0/16" | no |
| number_of_azs | Number of AZs | number | 3 | no |
| deployment_mode | Deployment mode | string | "ACTIVE_STANDBY_MULTI_AZ" | no |
| nlb_enabled | Create NLB | bool | false | no |
| create_self_signed_cert | Create self-signed cert | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| broker_id | MQ broker ID |
| broker_arn | MQ broker ARN |
| broker_endpoints | Broker endpoints |
| vpc_id | VPC ID |
| subnet_ids | Subnet IDs |
| nlb_dns_name | NLB DNS name |
| certificate_arn | Certificate ARN |
| self_signed_cert_pem | Self-signed certificate PEM |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.acm_issued](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate.self_signed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.instance_0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_lb_target_group_attachment.instance_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_mq_broker.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_broker) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [tls_private_key.main](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.main](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.provided](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDR blocks allowed to access the broker | `list(string)` | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply changes immediately | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Enable automatic minor version upgrades | `bool` | `true` | no |
| <a name="input_broker_name"></a> [broker\_name](#input\_broker\_name) | Name of the broker | `string` | n/a | yes |
| <a name="input_cert_common_name"></a> [cert\_common\_name](#input\_cert\_common\_name) | Common name for self-signed certificate | `string` | `null` | no |
| <a name="input_cert_domain_name"></a> [cert\_domain\_name](#input\_cert\_domain\_name) | Domain name for the certificate | `string` | `null` | no |
| <a name="input_cert_organization"></a> [cert\_organization](#input\_cert\_organization) | Organization for the certificate | `string` | `"Amazon MQ"` | no |
| <a name="input_cert_subject_alternative_names"></a> [cert\_subject\_alternative\_names](#input\_cert\_subject\_alternative\_names) | Subject alternative names for ACM certificate | `list(string)` | `[]` | no |
| <a name="input_cert_validation_method"></a> [cert\_validation\_method](#input\_cert\_validation\_method) | Certificate validation method: DNS or EMAIL | `string` | `"DNS"` | no |
| <a name="input_cert_validity_period_hours"></a> [cert\_validity\_period\_hours](#input\_cert\_validity\_period\_hours) | Validity period in hours for self-signed cert | `number` | `8760` | no |
| <a name="input_create_acm_certificate"></a> [create\_acm\_certificate](#input\_create\_acm\_certificate) | Request an ACM certificate | `bool` | `false` | no |
| <a name="input_create_route53_validation_records"></a> [create\_route53\_validation\_records](#input\_create\_route53\_validation\_records) | Create Route53 validation records | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Create a security group for the broker | `bool` | `true` | no |
| <a name="input_create_self_signed_cert"></a> [create\_self\_signed\_cert](#input\_create\_self\_signed\_cert) | Create a self-signed certificate | `bool` | `false` | no |
| <a name="input_deployment_mode"></a> [deployment\_mode](#input\_deployment\_mode) | Deployment mode: SINGLE\_INSTANCE, ACTIVE\_STANDBY\_MULTI\_AZ, or CLUSTER\_MULTI\_AZ | `string` | `"ACTIVE_STANDBY_MULTI_AZ"` | no |
| <a name="input_engine_type"></a> [engine\_type](#input\_engine\_type) | Type of broker engine: ActiveMQ or RabbitMQ | `string` | `"ActiveMQ"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version of the broker engine | `string` | `"5.18"` | no |
| <a name="input_host_instance_type"></a> [host\_instance\_type](#input\_host\_instance\_type) | Broker instance type | `string` | `"mq.m5.large"` | no |
| <a name="input_maintenance_day_of_week"></a> [maintenance\_day\_of\_week](#input\_maintenance\_day\_of\_week) | Day of week for maintenance window | `string` | `"SUNDAY"` | no |
| <a name="input_maintenance_time_of_day"></a> [maintenance\_time\_of\_day](#input\_maintenance\_time\_of\_day) | Time of day for maintenance window (HH:MM format) | `string` | `"03:00"` | no |
| <a name="input_maintenance_time_zone"></a> [maintenance\_time\_zone](#input\_maintenance\_time\_zone) | Time zone for maintenance window | `string` | `"UTC"` | no |
| <a name="input_nlb_certificate_arn"></a> [nlb\_certificate\_arn](#input\_nlb\_certificate\_arn) | Existing certificate ARN for NLB | `string` | `null` | no |
| <a name="input_nlb_enabled"></a> [nlb\_enabled](#input\_nlb\_enabled) | Create a Network Load Balancer | `bool` | `false` | no |
| <a name="input_nlb_internal"></a> [nlb\_internal](#input\_nlb\_internal) | Whether the NLB is internal | `bool` | `true` | no |
| <a name="input_nlb_listeners"></a> [nlb\_listeners](#input\_nlb\_listeners) | Map of NLB listener configurations | <pre>map(object({<br>    port        = number<br>    protocol    = string<br>    target_port = optional(number)<br>    ssl_policy  = optional(string)<br>  }))</pre> | <pre>{<br>  "openwire": {<br>    "port": 61617,<br>    "protocol": "TLS"<br>  }<br>}</pre> | no |
| <a name="input_number_of_azs"></a> [number\_of\_azs](#input\_number\_of\_azs) | Number of availability zones to use (1-6). Defaults to 1 for SINGLE\_INSTANCE, 3 for multi-AZ. | `number` | `null` | no |
| <a name="input_password"></a> [password](#input\_password) | Admin password for the broker | `string` | n/a | yes |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Whether the broker is publicly accessible | `bool` | `false` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route53 zone ID for DNS validation | `string` | `null` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name for the security group | `string` | `null` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of existing security group IDs | `list(string)` | `[]` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage type: efs or ebs | `string` | `"efs"` | no |
| <a name="input_subnet_cidrs"></a> [subnet\_cidrs](#input\_subnet\_cidrs) | List of CIDR blocks for subnets. Auto-calculated if not provided. | `list(string)` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of VPC subnet IDs. If not provided, subnets will be created automatically. | `list(string)` | `[]` | no |
| <a name="input_subnet_netnum_offset"></a> [subnet\_netnum\_offset](#input\_subnet\_netnum\_offset) | Starting offset for subnet numbering | `number` | `0` | no |
| <a name="input_subnet_newbits"></a> [subnet\_newbits](#input\_subnet\_newbits) | Number of bits to add to VPC CIDR for subnet calculation | `number` | `8` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | Admin username for the broker | `string` | `"admin"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the broker will be deployed. If not provided and subnet\_ids is empty, a new VPC will be created. | `string` | `null` | no |
| <a name="input_wait_for_certificate_validation"></a> [wait\_for\_certificate\_validation](#input\_wait\_for\_certificate\_validation) | Wait for certificate validation | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | Availability zones |
| <a name="output_broker_arn"></a> [broker\_arn](#output\_broker\_arn) | MQ broker ARN |
| <a name="output_broker_console_url"></a> [broker\_console\_url](#output\_broker\_console\_url) | Web console URL |
| <a name="output_broker_endpoints"></a> [broker\_endpoints](#output\_broker\_endpoints) | Broker endpoints |
| <a name="output_broker_id"></a> [broker\_id](#output\_broker\_id) | MQ broker ID |
| <a name="output_broker_instances"></a> [broker\_instances](#output\_broker\_instances) | MQ broker instances |
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | Certificate ARN |
| <a name="output_certificate_type"></a> [certificate\_type](#output\_certificate\_type) | Certificate type |
| <a name="output_certificate_validation_records"></a> [certificate\_validation\_records](#output\_certificate\_validation\_records) | DNS validation records for ACM certificate |
| <a name="output_nlb_arn"></a> [nlb\_arn](#output\_nlb\_arn) | NLB ARN |
| <a name="output_nlb_dns_name"></a> [nlb\_dns\_name](#output\_nlb\_dns\_name) | NLB DNS name |
| <a name="output_nlb_zone_id"></a> [nlb\_zone\_id](#output\_nlb\_zone\_id) | NLB zone ID |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID |
| <a name="output_self_signed_cert_pem"></a> [self\_signed\_cert\_pem](#output\_self\_signed\_cert\_pem) | Self-signed certificate PEM |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Subnet IDs |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END_TF_DOCS -->
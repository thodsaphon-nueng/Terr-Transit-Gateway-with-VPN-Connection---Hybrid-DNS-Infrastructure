resource "aws_route53_resolver_endpoint" "inbound" {
  name      = var.name
  direction = "INBOUND"

  security_group_ids = var.security_group_ids

  dynamic "ip_address" {
    for_each = var.ip_addresses
    content {
      subnet_id = ip_address.value.subnet_id
    }
  }

  tags = var.tags
}
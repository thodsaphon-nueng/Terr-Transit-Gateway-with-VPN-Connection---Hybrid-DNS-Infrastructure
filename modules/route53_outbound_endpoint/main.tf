resource "aws_route53_resolver_endpoint" "outbound" {
  name      = var.name
  direction = "OUTBOUND"

  security_group_ids = var.security_group_ids

  dynamic "ip_address" {
    for_each = var.ip_addresses
    content {
      subnet_id = ip_address.value.subnet_id
    }
  }

  tags = var.tags
}

# Resolver rules for forwarding specific domains
resource "aws_route53_resolver_rule" "forwarding" {
  count = length(var.forwarding_rules)

  domain_name          = var.forwarding_rules[count.index].domain_name
  name                 = var.forwarding_rules[count.index].name
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  dynamic "target_ip" {
    for_each = var.forwarding_rules[count.index].target_ips
    content {
      ip   = target_ip.value.ip
      port = target_ip.value.port
    }
  }

  tags = merge(var.tags, {
    Name = var.forwarding_rules[count.index].name
  })
}

# # Associate resolver rules with VPCs
# resource "aws_route53_resolver_rule_association" "this" {
#   count = length(var.forwarding_rules) > 0 ? length(var.vpc_ids) : 0

#   resolver_rule_id = aws_route53_resolver_rule.forwarding[count.index % length(var.forwarding_rules)].id
#   vpc_id           = var.vpc_ids[count.index % length(var.vpc_ids)]
# }
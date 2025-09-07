output "resolver_endpoint_id" {
  description = "The ID of the outbound resolver endpoint"
  value       = aws_route53_resolver_endpoint.outbound.id
}

output "resolver_endpoint_arn" {
  description = "The ARN of the outbound resolver endpoint"
  value       = aws_route53_resolver_endpoint.outbound.arn
}

# output "resolver_endpoint_hosted_zone_id" {
#   description = "The hosted zone ID of the outbound resolver endpoint"
#   value       = aws_route53_resolver_endpoint.outbound.hosted_zone_id
# }

output "resolver_endpoint_ip_addresses" {
  description = "List of IP addresses for the outbound resolver endpoint"
  value       = aws_route53_resolver_endpoint.outbound.ip_address
}

output "resolver_rule_ids" {
  description = "List of resolver rule IDs"
  value       = aws_route53_resolver_rule.forwarding[*].id
}

output "resolver_rule_arns" {
  description = "List of resolver rule ARNs"
  value       = aws_route53_resolver_rule.forwarding[*].arn
}


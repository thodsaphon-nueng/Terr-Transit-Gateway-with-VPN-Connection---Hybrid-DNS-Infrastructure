output "resolver_endpoint_id" {
  description = "The ID of the resolver endpoint"
  value       = aws_route53_resolver_endpoint.inbound.id
}

output "resolver_endpoint_arn" {
  description = "The ARN of the resolver endpoint"
  value       = aws_route53_resolver_endpoint.inbound.arn
}

# output "resolver_endpoint_hosted_zone_id" {
#   description = "The hosted zone ID of the resolver endpoint"
#   value       = aws_route53_resolver_endpoint.inbound.hosted_zone_id
# }

output "resolver_endpoint_ip_addresses" {
  description = "List of IP addresses for the resolver endpoint"
  value       = aws_route53_resolver_endpoint.inbound.ip_address
}


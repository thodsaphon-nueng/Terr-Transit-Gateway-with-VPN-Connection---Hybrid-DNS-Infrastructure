output "zone_id" {
  description = "The hosted zone ID"
  value       = aws_route53_zone.this.zone_id
}

output "zone_arn" {
  description = "The hosted zone ARN"
  value       = aws_route53_zone.this.arn
}

output "name_servers" {
  description = "A list of name servers in associated (or default) delegation set"
  value       = aws_route53_zone.this.name_servers
}

output "primary_name_server" {
  description = "The primary name server for the hosted zone"
  value       = aws_route53_zone.this.primary_name_server
}

output "zone_name" {
  description = "The name of the hosted zone"
  value       = aws_route53_zone.this.name
}
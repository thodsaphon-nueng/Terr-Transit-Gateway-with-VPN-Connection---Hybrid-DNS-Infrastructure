output "nat_gateway_id" {
  value = aws_nat_gateway.this.id
}

output "nat_gateway_ip" {
  value = aws_nat_gateway.this.public_ip
}

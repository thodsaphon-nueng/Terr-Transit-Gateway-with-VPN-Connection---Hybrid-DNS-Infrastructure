resource "aws_vpn_connection" "this" {
  vpn_gateway_id      = var.vpn_gateway_id
  customer_gateway_id = var.customer_gateway_id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = var.name
  }
}

resource "aws_vpn_connection_route" "this" {
  count                 = length(var.static_routes)
  vpn_connection_id     = aws_vpn_connection.this.id
  destination_cidr_block = var.static_routes[count.index]
}

resource "aws_route" "this" {
  route_table_id            = var.route_table_id
  destination_cidr_block    = var.destination_cidr_block
  nat_gateway_id            = var.nat_gateway_id
  gateway_id                = var.gateway_id
  transit_gateway_id        = var.transit_gateway_id
  vpc_peering_connection_id = var.vpc_peering_connection_id
  network_interface_id               = var.network_interface_id
}


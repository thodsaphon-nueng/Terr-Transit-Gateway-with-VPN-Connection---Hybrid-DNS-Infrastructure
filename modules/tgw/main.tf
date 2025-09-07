resource "aws_ec2_transit_gateway" "this" {
  description         = var.name
  amazon_side_asn     = var.amazon_side_asn

  auto_accept_shared_attachments    = "enable"
  default_route_table_association   = "disable"
  default_route_table_propagation   = "disable"

  tags = {
    Name = var.name
  }
}

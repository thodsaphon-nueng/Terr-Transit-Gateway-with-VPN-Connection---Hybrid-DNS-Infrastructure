resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id = var.attachment_id
  transit_gateway_route_table_id = var.route_table_id
}

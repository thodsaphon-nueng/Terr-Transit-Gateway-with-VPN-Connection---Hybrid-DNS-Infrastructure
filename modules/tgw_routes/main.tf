

resource "aws_ec2_transit_gateway_route" "this" {
  for_each = {
    for idx, route in var.routes :
    idx => route
  }

  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = each.value.attachment_id
  transit_gateway_route_table_id = var.route_table_id
}

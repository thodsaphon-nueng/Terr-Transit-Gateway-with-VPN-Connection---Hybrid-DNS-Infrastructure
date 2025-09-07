resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  transit_gateway_id  = var.transit_gateway_id

  tags = {
    Name = var.name
  }
}

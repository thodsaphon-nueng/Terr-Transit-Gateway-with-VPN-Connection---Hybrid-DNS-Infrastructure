resource "aws_customer_gateway" "this" {
  bgp_asn    = var.bgp_asn
  ip_address = var.ip_address
  type       = "ipsec.1"

  tags = {
    Name = var.name
  }
}

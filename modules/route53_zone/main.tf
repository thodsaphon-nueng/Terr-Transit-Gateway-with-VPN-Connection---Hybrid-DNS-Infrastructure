resource "aws_route53_zone" "this" {
  name          = var.name
  comment       = var.comment
  force_destroy = var.force_destroy

  # Public Zone (default)
  dynamic "vpc" {
    for_each = var.vpc_id != null ? [1] : []
    content {
      vpc_id     = var.vpc_id
      vpc_region = var.vpc_region
    }
  }

  tags = var.tags
}


resource "aws_route53_zone_association" "additional" {
  for_each = toset(var.additional_vpc_ids)
  
  zone_id = aws_route53_zone.this.zone_id
  vpc_id  = each.value
}
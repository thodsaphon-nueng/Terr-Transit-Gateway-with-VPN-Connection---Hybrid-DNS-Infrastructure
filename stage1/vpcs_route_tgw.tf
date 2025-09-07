
#vpc cloud
module "vpc_cloud_route_to_tgw_cloud_b" {
  source                 = "../modules/route"
  route_table_id         = module.private_subnet_cloud_b.route_table_id
  destination_cidr_block = module.vpc_cloud_b.cidr_block
  transit_gateway_id     = module.tgw.id
}
module "vpc_cloud_route_to_tgw_cloud_c" {
  source                 = "../modules/route"
  route_table_id         = module.private_subnet_cloud_b.route_table_id
  destination_cidr_block = module.vpc_cloud_c.cidr_block
  transit_gateway_id     = module.tgw.id
}


#vpc cloud_b
module "vpc_cloud_b_route_to_tgw_cloud" {
  source                 = "../modules/route"
  route_table_id         = module.private_cloud_b_subnet_a.route_table_id
  destination_cidr_block = module.vpc_cloud.cidr_block
  transit_gateway_id     = module.tgw.id
}

#vpc cloud_c
module "vpc_cloud_c_route_to_tgw_cloud" {
  source                 = "../modules/route"
  route_table_id         = module.private_cloud_c_subnet_a.route_table_id
  destination_cidr_block = module.vpc_cloud.cidr_block
  transit_gateway_id     = module.tgw.id
}
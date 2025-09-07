module "tgw" {
  source = "../modules/tgw"
  name   = "main-tgw"
}

module "rt_cloud" {
  source             = "../modules/tgw_route_table"
  name               = "tgw-rt-cloud"
  transit_gateway_id = module.tgw.id
}

module "rt_cloud_b" {
  source             = "../modules/tgw_route_table"
  name               = "tgw-rt-cloud-b"
  transit_gateway_id = module.tgw.id
}

module "rt_cloud_c" {
  source             = "../modules/tgw_route_table"
  name               = "tgw-rt-cloud-c"
  transit_gateway_id = module.tgw.id
}

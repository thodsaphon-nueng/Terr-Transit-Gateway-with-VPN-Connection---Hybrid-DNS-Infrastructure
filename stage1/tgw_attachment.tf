module "attach_cloud" {
  source              = "../modules/tgw_attachment"
  name                = "attach-cloud"
  vpc_id              = module.vpc_cloud.vpc_id
  subnet_ids          = [module.private_subnet_cloud_b.subnet_id]
  transit_gateway_id  = module.tgw.id
}

module "attach_cloud_b" {
  source              = "../modules/tgw_attachment"
  name                = "attach-cloud-b"
  vpc_id              = module.vpc_cloud_b.vpc_id
  subnet_ids          = [module.private_cloud_b_subnet_a.subnet_id]
  transit_gateway_id  = module.tgw.id
}

module "attach_cloud_c" {
  source              = "../modules/tgw_attachment"
  name                = "attach-cloud-c"
  vpc_id              = module.vpc_cloud_c.vpc_id
  subnet_ids          = [module.private_cloud_c_subnet_a.subnet_id]
  transit_gateway_id  = module.tgw.id
}

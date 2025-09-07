# CLOUD → CLOUD-B, CLOUD-C
module "routes_cloud" {
  source         = "../modules/tgw_routes"
  route_table_id = module.rt_cloud.id
  routes = [
    {
      destination_cidr_block = module.vpc_cloud_b.cidr_block
      attachment_id          = module.attach_cloud_b.attachment_id
    },
    {
      destination_cidr_block = module.vpc_cloud_c.cidr_block
      attachment_id          = module.attach_cloud_c.attachment_id
    }
  ]
}

# CLOUD-B → CLOUD
module "routes_cloud_b" {
  source         = "../modules/tgw_routes"
  route_table_id = module.rt_cloud_b.id
  routes = [
    {
      destination_cidr_block = module.vpc_cloud.cidr_block
      attachment_id          = module.attach_cloud.attachment_id
    }
  ]
}

# CLOUD-C → CLOUD
module "routes_cloud_c" {
  source         = "../modules/tgw_routes"
  route_table_id = module.rt_cloud_c.id
  routes = [
    {
      destination_cidr_block = module.vpc_cloud.cidr_block
      attachment_id          = module.attach_cloud.attachment_id
    }
  ]
}

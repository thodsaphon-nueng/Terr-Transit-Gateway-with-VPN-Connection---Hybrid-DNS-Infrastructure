module "rt_assoc_cloud" {
  source         = "../modules/tgw_rt_association"
  attachment_id  = module.attach_cloud.attachment_id
  route_table_id = module.rt_cloud.id
}

module "rt_assoc_cloud_b" {
  source         = "../modules/tgw_rt_association"
  attachment_id  = module.attach_cloud_b.attachment_id
  route_table_id = module.rt_cloud_b.id
}


module "rt_assoc_cloud_c" {
  source         = "../modules/tgw_rt_association"
  attachment_id  = module.attach_cloud_c.attachment_id
  route_table_id = module.rt_cloud_c.id
}

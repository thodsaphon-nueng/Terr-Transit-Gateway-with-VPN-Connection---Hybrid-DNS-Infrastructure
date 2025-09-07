data "terraform_remote_state" "stage1_dns" {
  backend = "local"

  config = {
    path = "../stage1/terraform.tfstate"
  }
}


module "private_zone" {
  source     = "../modules/route53_zone"
  name       = "cloud.com"
  comment    = "Private hosted zone for internal services"
  vpc_id     = data.terraform_remote_state.stage1_dns.outputs.cloud_vpc_id
  vpc_region = var.region

  #   additional_vpc_ids = [
  #     module.vpc_dev.vpc_id,
  #     module.vpc_staging.vpc_id
  #   ]

}

module "internal_api" {
  source = "../modules/route53_record"
  zone_id = module.private_zone.zone_id
  name    = "api"
  type    = "A"
  ttl     = 300
  records = [data.terraform_remote_state.stage1_dns.outputs.ec2_cloud_private_ip]
}
data "terraform_remote_state" "stage1" {
  backend = "local"

  config = {
    path = "../stage1/terraform.tfstate"
  }
}


# cloud public
# for statiic
# module "public_route_cloud_vpn" {
#   source                = "../modules/route"
#   route_table_id        = data.terraform_remote_state.stage1.outputs.public_subnet_cloud_route_table_id
#   destination_cidr_block = "10.100.0.0/16"
#   gateway_id            = data.terraform_remote_state.stage1.outputs.vpn_gateway_cloud_vpn_gateway_id
# }
resource "aws_vpn_gateway_route_propagation" "public_route_cloud_vpn_propagation" {
  vpn_gateway_id = data.terraform_remote_state.stage1.outputs.vpn_gateway_cloud_vpn_gateway_id
  route_table_id = data.terraform_remote_state.stage1.outputs.public_subnet_cloud_route_table_id
}


# cloud private b
# for statiic
# module "private_cloud_b_route_cloud_vpn" {
#   source                = "../modules/route"
#   route_table_id        = data.terraform_remote_state.stage1.outputs.private_subnet_cloud_b_route_table_id
#   destination_cidr_block = "10.100.0.0/16"
#   gateway_id            = data.terraform_remote_state.stage1.outputs.vpn_gateway_cloud_vpn_gateway_id
# }
resource "aws_vpn_gateway_route_propagation" "private_cloud_b_route_table_propagation" {
  vpn_gateway_id = data.terraform_remote_state.stage1.outputs.vpn_gateway_cloud_vpn_gateway_id
  route_table_id = data.terraform_remote_state.stage1.outputs.private_subnet_cloud_b_route_table_id
}



# onprem private b to vpn server
module "private_onprem_b_route_cloud_vpn" {
  source                 = "../modules/route"
  route_table_id         = data.terraform_remote_state.stage1.outputs.private_subnet_onprem_b_route_table_id
  destination_cidr_block = "10.0.0.0/16"
  network_interface_id   = data.terraform_remote_state.stage1.outputs.vpn_server_ec2_on_premise_network_interface_id
}
# onprem private a to vpn server
module "private_onprem_a_route_cloud_vpn" {
  source                 = "../modules/route"
  route_table_id         = data.terraform_remote_state.stage1.outputs.private_subnet_onprem_a_route_table_id
  destination_cidr_block = "10.0.0.0/16"
  network_interface_id   = data.terraform_remote_state.stage1.outputs.vpn_server_ec2_on_premise_network_interface_id
}



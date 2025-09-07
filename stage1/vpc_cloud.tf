module "vpc_cloud" {
  source     = "../modules/vpc"
  cidr_block = "10.0.0.0/16"
  name       = "vpc_cloud"
}

module "igw_cloud" {
  source = "../modules/igw"
  vpc_id = module.vpc_cloud.vpc_id
  name   = "igw_cloud"
}


module "public_subnet_cloud" {
  source                  = "../modules/subnet"
  vpc_id                  = module.vpc_cloud.vpc_id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.az1
  map_public_ip_on_launch = true
  name                    = "public_subnet_cloud"
}



module "public_route_cloud" {
  source                = "../modules/route"
  route_table_id        = module.public_subnet_cloud.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id            = module.igw_cloud.internet_gateway_id
}



module "private_subnet_cloud_a" {
  source                  = "../modules/subnet"
  vpc_id                  = module.vpc_cloud.vpc_id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = var.az2
  map_public_ip_on_launch = false
  name                    = "private_subnet_cloud_a"
}


module "private_subnet_cloud_b" {
  source                  = "../modules/subnet"
  vpc_id                  = module.vpc_cloud.vpc_id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = var.az1
  map_public_ip_on_launch = false
  name                    = "private_subnet_cloud_b"
}



module "app_sg_cloud" {
  source = "../modules/sg"
  name   = "app_sg_cloud"
  vpc_id = module.vpc_cloud.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH from anywhere"
    },

    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["10.100.0.0/16"]
      description = "Allow ICMP Ping"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]
}


module "app_ec2_cloud" {
  source                      = "../modules/ec2"
  ami                         = "ami-0779c82fbb81e731c"
  instance_type               = "t3.micro"
  subnet_id                   = module.public_subnet_cloud.subnet_id
  associate_public_ip_address = true
  key_name                    = "ssh-key"
  security_group_ids          = [module.app_sg_cloud.security_group_id]
  name                        = "app_ec2_cloud"
}




module "app_sg_prvivate_b" {
  source = "../modules/sg"
  name   = "app_sg_prvivate_b"
  vpc_id = module.vpc_cloud.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Allow SSH from anywhere"
    },

    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow ICMP Ping"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]
}


module "app_ec2_cloud_private_b" {
  source                      = "../modules/ec2"
  ami                         = "ami-0779c82fbb81e731c"
  instance_type               = "t3.micro"
  subnet_id                   = module.private_subnet_cloud_b.subnet_id
  associate_public_ip_address = true
  key_name                    = "ssh-key"
  security_group_ids          = [module.app_sg_prvivate_b.security_group_id]
  name                        = "app_ec2_cloud_private_b"
}


# VPN GATWAY
module "vpn_gateway_cloud" {
  source = "../modules/vpn_virtual_gateway"
  vpc_id = module.vpc_cloud.vpc_id
  name   = "vpn_gateway_cloud"
}
module "customer_gateway_on_premise" {
  source     = "../modules/vpn_customer_gateway"
  ip_address = module.vpn_server_ec2_on_premise.public_ip
  name       = "customer_gateway_on_premise"
}
module "vpn_connection_cloud_to_on_premise" {
  source              = "../modules/vpn_connection"
  vpn_gateway_id      = module.vpn_gateway_cloud.vpn_gateway_id
  customer_gateway_id = module.customer_gateway_on_premise.customer_gateway_id
  name                = "vpn_connection_cloud_to_on_premise"
  static_routes       = ["10.100.0.0/16"]
}



# -------------- Output

output "vpn_gateway_cloud_vpn_gateway_id" {
  value = module.vpn_gateway_cloud.vpn_gateway_id
}



output "public_subnet_cloud_route_table_id" {
  value = module.public_subnet_cloud.route_table_id
}
output "private_subnet_cloud_a_route_table_id" {
  value = module.private_subnet_cloud_a.route_table_id
}
output "private_subnet_cloud_b_route_table_id" {
  value = module.private_subnet_cloud_b.route_table_id
}

output "cloud_vpc_id" {
  value = module.vpc_cloud.vpc_id
}

output "private_subnet_cloud_a_id" {
  value = module.private_subnet_cloud_a.subnet_id
}

output "private_subnet_cloud_b_id" {
  value = module.private_subnet_cloud_b.subnet_id
}

output "ec2_cloud_private_ip" {
  value = module.app_ec2_cloud.private_ip
}

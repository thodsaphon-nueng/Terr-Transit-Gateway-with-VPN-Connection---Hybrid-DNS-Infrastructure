module "vpc_cloud_c" {
  source     = "../modules/vpc"
  cidr_block = "10.3.0.0/16"
  name       = "vpc_cloud_c"
}

module "igw_cloud_c" {
  source = "../modules/igw"
  vpc_id = module.vpc_cloud_c.vpc_id
  name   = "igw_cloud_c"
}


module "public_subnet_cloud_c" {
  source                  = "../modules/subnet"
  vpc_id                  = module.vpc_cloud_c.vpc_id
  cidr_block              = "10.3.0.0/24"
  availability_zone       = var.az1
  map_public_ip_on_launch = true
  name                    = "public_subnet_cloud_c"
}


module "public_route_cloud_c" {
  source                = "../modules/route"
  route_table_id        = module.public_subnet_cloud_c.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id            = module.igw_cloud_c.internet_gateway_id
}


module "bastion_sg_cloud_c" {
  source = "../modules/sg"
  name   = "bastion_sg_cloud_c"
  vpc_id = module.vpc_cloud_c.vpc_id

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
      cidr_blocks = ["10.3.0.0/16"]
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


module "bastion_ec2_cloud_c" {
  source                      = "../modules/ec2"
  ami                         = "ami-0779c82fbb81e731c"
  instance_type               = "t3.micro"
  subnet_id                   = module.public_subnet_cloud_c.subnet_id
  associate_public_ip_address = true
  key_name                    = "ssh-key"
  security_group_ids          = [module.bastion_sg_cloud_c.security_group_id]
  name                        = "bastion_ec2_cloud_c"
}


module "private_cloud_c_subnet_a" {
  source                  = "../modules/subnet"
  vpc_id                  = module.vpc_cloud_c.vpc_id
  cidr_block              = "10.3.10.0/24"
  availability_zone       = var.az2
  map_public_ip_on_launch = false
  name                    = "private_cloud_c_subnet_a"
}


# module "ec2_cloud_c_private_subnet_a_sg" {
#   source = "../modules/sg"
#   name   = "ec2_cloud_c_private_subnet_a_sg"
#   vpc_id = module.vpc_cloud_c.vpc_id

#   ingress_rules = [
#     {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       cidr_blocks = ["10.3.0.0/16"]
#       description = "Allow SSH from anywhere"
#     },

#     {
#       from_port   = -1
#       to_port     = -1
#       protocol    = "icmp"
#       cidr_blocks = ["10.3.0.0/16"]
#       description = "Allow ICMP Ping"
#     },

# {
#       from_port   = -1
#       to_port     = -1
#       protocol    = "icmp"
#       cidr_blocks = ["10.0.0.0/16"]
#       description = "Allow ICMP Ping"
#     }
#   ]

#   egress_rules = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["10.3.0.0/16"]
#       description = "Allow all outbound"
#     }
#   ]
# }


# module "ec2_cloud_c_private_subnet_a" {
#   source                      = "../modules/ec2"
#   ami                         = "ami-0779c82fbb81e731c"
#   instance_type               = "t3.micro"
#   subnet_id                   = module.private_cloud_c_subnet_a.subnet_id
#   associate_public_ip_address = true
#   key_name                    = "ssh-key"
#   security_group_ids          = [module.ec2_cloud_c_private_subnet_a_sg.security_group_id]
#   name                        = "ec2_cloud_c_private_subnet_a"
# }
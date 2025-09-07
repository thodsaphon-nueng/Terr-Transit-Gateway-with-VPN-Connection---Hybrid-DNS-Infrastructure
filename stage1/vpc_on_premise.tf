module "vpc_on_premise" {
  source     = "../modules/vpc"
  cidr_block = "10.100.0.0/16"
  name       = "vpc_on_premise"
}

module "igw_on_premise" {
  source = "../modules/igw"
  vpc_id = module.vpc_on_premise.vpc_id
  name   = "igw_on_premise"
}


module "public_subnet_on_premise" {
  source                  = "../modules/subnet"
  vpc_id                  = module.vpc_on_premise.vpc_id
  cidr_block              = "10.100.0.0/24"
  availability_zone       = var.az1
  map_public_ip_on_launch = true
  name                    = "public_subnet_on_premise"
}



module "public_route_on_premise" {
  source                 = "../modules/route"
  route_table_id         = module.public_subnet_on_premise.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.igw_on_premise.internet_gateway_id
}



module "private_subnet_on_premise_a" {
  source                  = "../modules/subnet"
  vpc_id                  = module.vpc_on_premise.vpc_id
  cidr_block              = "10.100.10.0/24"
  availability_zone       = var.az1
  map_public_ip_on_launch = false
  name                    = "private_subnet_on_premise_a"
}


# aws_eip and NAT on public subnet
resource "aws_eip" "nat_eip_on_premise" {
  domain = "vpc"

  tags = {
    Name = "nat_eip_on_premise"
  }
}
module "nat_gateway_on_premise" {
  source        = "../modules/nat_gateway"
  allocation_id = aws_eip.nat_eip_on_premise.id
  subnet_id     = module.public_subnet_on_premise.subnet_id
  name          = "nat_gateway_on_premise"
}


module "private_subnet_on_premise_b" {
  source                  = "../modules/subnet"
  vpc_id                  = module.vpc_on_premise.vpc_id
  cidr_block              = "10.100.11.0/24"
  availability_zone       = var.az1
  map_public_ip_on_launch = false
  name                    = "private_subnet_on_premise_b"
}


module "private_route_on_premise_b" {
  source                 = "../modules/route"
  route_table_id         = module.private_subnet_on_premise_b.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.nat_gateway_on_premise.nat_gateway_id
}


module "private_route_on_premise_a" {
  source                 = "../modules/route"
  route_table_id         = module.private_subnet_on_premise_a.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.nat_gateway_on_premise.nat_gateway_id
}


# security group and ec2 on public subnet 
module "vpn_server_sg_on_premise" {
  source = "../modules/sg"
  name   = "vpn_server_sg_on_premise"
  vpc_id = module.vpc_on_premise.vpc_id

  ingress_rules = [

    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH from anywhere"
    }
    ,
    {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      cidr_blocks = ["10.100.0.0/16"]
      description = "Allow DNS (UDP)"
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
module "vpn_server_ec2_on_premise" {
  source                      = "../modules/ec2"
  ami                         = "ami-0779c82fbb81e731c"
  instance_type               = "t3.micro"
  subnet_id                   = module.public_subnet_on_premise.subnet_id
  associate_public_ip_address = true
  key_name                    = "ssh-key"
  source_dest_check           = false
  security_group_ids          = [module.vpn_server_sg_on_premise.security_group_id]
  name                        = "vpn_server_ec2_on_premise"
}


# security group and ec2 on private subnet b
module "app_sg_on_premise" {
  source = "../modules/sg"
  name   = "app_sg_on_premise"
  vpc_id = module.vpc_on_premise.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.100.0.0/16"]
      description = "Allow SSH from anywhere"
    },

    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["10.100.0.0/16"]
      description = "Allow ICMP Ping"
    },


    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["10.0.0.0/16"]
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
module "app_ec2_on_premise" {
  source        = "../modules/ec2"
  ami           = "ami-0779c82fbb81e731c"
  instance_type = "t3.micro"
  subnet_id     = module.private_subnet_on_premise_b.subnet_id

  key_name           = "ssh-key"
  security_group_ids = [module.app_sg_on_premise.security_group_id]
  name               = "app_ec2_on_premise"
}




# security group and ec2 on private subnet a
module "dns_server_sg_on_premise" {
  source = "../modules/sg"
  name   = "dns_server_sg_on_premise"
  vpc_id = module.vpc_on_premise.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.100.0.0/16"]
      description = "Allow SSH from anywhere"
    },

    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["10.100.0.0/16"]
      description = "Allow ICMP Ping"
    },

    {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      cidr_blocks = ["10.100.0.0/16"]
      description = "Allow DNS (UDP)"
    },

    {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Allow DNS (UDP)"
    },
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
module "dns_server_ec2_on_premise" {
  source        = "../modules/ec2"
  ami           = "ami-0779c82fbb81e731c"
  instance_type = "t3.micro"
  subnet_id     = module.private_subnet_on_premise_a.subnet_id

  key_name           = "ssh-key"
  security_group_ids = [module.dns_server_sg_on_premise.security_group_id]
  name               = "dns_server_ec2_on_premise"
}


# -------------- Output

output "vpn_server_ec2_on_premise_network_interface_id" {
  value = module.vpn_server_ec2_on_premise.network_interface_id
}

output "vpn_server_ec2_on_premise_public_ip" {
  value = module.vpn_server_ec2_on_premise.public_ip
}

output "dns_server_ec2_on_premise_private_ip" {
  value = module.dns_server_ec2_on_premise.private_ip
}

output "private_subnet_onprem_b_route_table_id" {
  value = module.private_subnet_on_premise_b.route_table_id
}

output "private_subnet_onprem_a_route_table_id" {
  value = module.private_subnet_on_premise_a.route_table_id
}


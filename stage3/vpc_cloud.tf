data "terraform_remote_state" "stage1_in_ou_dns" {
  backend = "local"
  config = {
    path = "../stage1/terraform.tfstate"
  }
}

# Security Group for Inbound Endpoint
module "inbound_endpoint_sg" {
  source = "../modules/sg"
  
  name   = "inbound_endpoint_sg"
  vpc_id = data.terraform_remote_state.stage1_in_ou_dns.outputs.cloud_vpc_id
  
  ingress_rules = [
    {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      cidr_blocks = ["10.100.0.0/16"]
      description = "Allow DNS (UDP) from on-premises"
    },
    {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      cidr_blocks = ["10.100.0.0/16"]
      description = "Allow DNS (TCP) from on-premises"
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

# Inbound Endpoint
module "inbound_endpoint" {
  source = "../modules/route53_inbound_endpoint"
  
  name               = "corporate-inbound-resolver"
  security_group_ids = [module.inbound_endpoint_sg.security_group_id]
  
  ip_addresses = [
    {
      subnet_id = data.terraform_remote_state.stage1_in_ou_dns.outputs.private_subnet_cloud_a_id
    },
    {
      subnet_id = data.terraform_remote_state.stage1_in_ou_dns.outputs.private_subnet_cloud_b_id
    }
  ]
  
  tags = {
    Purpose = "Allow on-premises to query AWS private zones"
  }
}

# Security Group for Outbound Endpoint
module "outbound_endpoint_sg" {
  source = "../modules/sg"
  
  name   = "outbound_endpoint_sg"
  vpc_id = data.terraform_remote_state.stage1_in_ou_dns.outputs.cloud_vpc_id
  
  ingress_rules = [
    {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "Allow DNS queries from VPC"
    },
    {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "Allow DNS queries from VPC"
    }
  ]
  
  egress_rules = [
    {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      cidr_blocks = ["10.100.0.0/16"]
      description = "Allow DNS queries to on-premises"
    },
    {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      cidr_blocks = ["10.100.0.0/16"]
      description = "Allow DNS queries to on-premises"
    }
  ]
}

# Outbound Endpoint
module "outbound_endpoint" {
  source = "../modules/route53_outbound_endpoint"
  
  name               = "corporate-outbound-resolver"
  security_group_ids = [module.outbound_endpoint_sg.security_group_id]  # ← แก้ไขตรงนี้
  
  ip_addresses = [
    {
      subnet_id = data.terraform_remote_state.stage1_in_ou_dns.outputs.private_subnet_cloud_a_id
    },
    {
      subnet_id = data.terraform_remote_state.stage1_in_ou_dns.outputs.private_subnet_cloud_b_id
    }
  ]
  
  # Forward specific domains to on-premises DNS
  forwarding_rules = [
    {
      domain_name = "onprem.com"
      name        = "onprem-rule"
      target_ips = [
        {
          ip   = data.terraform_remote_state.stage1_in_ou_dns.outputs.dns_server_ec2_on_premise_private_ip
          port = 53
        }
      ]
    }
  ]
  
  tags = {
    Purpose = "Forward on-premises domains from AWS"
  }
}

# Associate resolver rules with VPC
resource "aws_route53_resolver_rule_association" "main" {
  count = length(module.outbound_endpoint.resolver_rule_ids)
  
  resolver_rule_id = module.outbound_endpoint.resolver_rule_ids[count.index]
  vpc_id           = data.terraform_remote_state.stage1_in_ou_dns.outputs.cloud_vpc_id
}

# Outputs
output "inbound_endpoint_resolver_endpoint_ip_addresses" {
  description = "IP addresses for inbound resolver - configure these in on-premises DNS"
  value       = module.inbound_endpoint.resolver_endpoint_ip_addresses
}

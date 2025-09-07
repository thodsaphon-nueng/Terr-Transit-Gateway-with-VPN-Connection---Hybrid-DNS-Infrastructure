variable "name" {
  description = "Name of the outbound resolver endpoint"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for the resolver endpoint"
  type        = list(string)
  default     = []
}

variable "ip_addresses" {
  description = "List of IP addresses for the resolver endpoint"
  type = list(object({
    subnet_id = string
  }))
  
  validation {
    condition     = length(var.ip_addresses) >= 2
    error_message = "At least 2 IP addresses must be specified for high availability."
  }
}

variable "forwarding_rules" {
  description = "List of forwarding rules"
  type = list(object({
    domain_name = string
    name        = string
    target_ips = list(object({
      ip   = string
      port = optional(number, 53)
    }))
  }))
  default = []
}

variable "vpc_ids" {
  description = "List of VPC IDs to associate with resolver rules"
  type        = list(string)
  default     = []
}


variable "vpc_id" {
  description = "VPC ID (required if create_security_group is true)"
  type        = string
  default     = null
}

variable "target_dns_servers" {
  description = "CIDR blocks of target DNS servers for outbound queries"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to use the outbound resolver"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

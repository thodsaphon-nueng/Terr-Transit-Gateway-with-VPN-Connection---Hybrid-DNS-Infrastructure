variable "name" {
  description = "Name of the inbound resolver endpoint"
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



variable "vpc_id" {
  description = "VPC ID (required if create_security_group is true)"
  type        = string
  default     = null
}


variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
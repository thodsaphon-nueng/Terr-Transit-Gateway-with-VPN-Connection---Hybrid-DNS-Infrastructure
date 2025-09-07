variable "allocation_id" {
  description = "Elastic IP Allocation ID for the NAT Gateway"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the public subnet where NAT Gateway will be deployed"
  type        = string
}

variable "name" {
  description = "Name tag for the NAT Gateway"
  type        = string
}

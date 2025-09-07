variable "route_table_id" {
  type        = string
  description = "ID ของ route table ที่จะเพิ่ม route เข้าไป"
}

variable "destination_cidr_block" {
  type        = string
  description = "Destination CIDR สำหรับ route"
}

variable "gateway_id" {
  type        = string
  description = "Internet Gateway ID (ใช้กับ public subnet)"
  default     = null
}

variable "nat_gateway_id" {
  type        = string
  description = "NAT Gateway ID (ใช้กับ private subnet)"
  default     = null
}

variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID (optional)"
  default     = null
}

variable "vpc_peering_connection_id" {
  type        = string
  description = "VPC Peering ID (optional)"
  default     = null
}


variable "network_interface_id" {
  type        = string
  description = ""
  default     = null
}

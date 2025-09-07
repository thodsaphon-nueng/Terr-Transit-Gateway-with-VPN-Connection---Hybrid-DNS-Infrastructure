variable "vpn_gateway_id" {
  type = string
}

variable "customer_gateway_id" {
  type = string
}

variable "name" {
  type = string
}

variable "static_routes" {
  type    = list(string)
  default = []
}

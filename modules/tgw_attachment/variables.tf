variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "transit_gateway_id" {
  type = string
}

variable "name" {
  type = string
}

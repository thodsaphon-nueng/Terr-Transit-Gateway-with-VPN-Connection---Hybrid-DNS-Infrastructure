variable "route_table_id" {
  type = string
}

variable "routes" {
  type = list(object({
    destination_cidr_block = string
    attachment_id          = string
  }))
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "associate_public_ip_address" {
  type    = bool
  default = false
}

variable "source_dest_check" {
  type    = bool
  default = true
}

variable "name" {
  type = string
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}
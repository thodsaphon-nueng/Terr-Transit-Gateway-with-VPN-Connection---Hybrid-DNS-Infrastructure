variable "name" {
  description = "The name of the hosted zone"
  type        = string
}

variable "comment" {
  description = "A comment for the hosted zone"
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "Whether to destroy all records when destroying the zone"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for private hosted zone (leave null for public zone)"
  type        = string
  default     = null
}

variable "vpc_region" {
  description = "VPC region for private hosted zone"
  type        = string
  default     = null
}

variable "additional_vpc_ids" {
  description = "Additional VPC IDs to associate with private hosted zone"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
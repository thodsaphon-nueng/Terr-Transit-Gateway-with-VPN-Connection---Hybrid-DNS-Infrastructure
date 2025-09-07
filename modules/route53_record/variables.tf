variable "zone_id" {
  description = "The ID of the hosted zone to contain this record"
  type        = string
}

variable "name" {
  description = "The name of the record"
  type        = string
}

variable "type" {
  description = "The record type (A, AAAA, CAA, CNAME, MX, NAPTR, NS, PTR, SOA, SPF, SRV, TXT)"
  type        = string
}

variable "ttl" {
  description = "The TTL of the record"
  type        = number
  default     = 300
}

variable "records" {
  description = "A string list of records"
  type        = list(string)
  default     = null
}

variable "set_identifier" {
  description = "Unique identifier to differentiate records with routing policies"
  type        = string
  default     = null
}

variable "health_check_id" {
  description = "The health check the record should be associated with"
  type        = string
  default     = null
}

variable "multivalue_answer_routing_policy" {
  description = "Enable multivalue answer routing policy"
  type        = bool
  default     = null
}

variable "allow_overwrite" {
  description = "Allow creation of this record to overwrite an existing record"
  type        = bool
  default     = false
}

variable "alias" {
  description = "An alias block"
  type = object({
    name                   = string
    zone_id                = string
    evaluate_target_health = bool
  })
  default = null
}

variable "weighted_routing_policy" {
  description = "A weighted routing policy block"
  type = object({
    weight = number
  })
  default = null
}

variable "latency_routing_policy" {
  description = "A latency routing policy block"
  type = object({
    region = string
  })
  default = null
}

variable "geolocation_routing_policy" {
  description = "A geolocation routing policy block"
  type = object({
    continent   = optional(string)
    country     = optional(string)
    subdivision = optional(string)
  })
  default = null
}

variable "failover_routing_policy" {
  description = "A failover routing policy block"
  type = object({
    type = string
  })
  default = null
}
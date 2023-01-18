variable "domain_entry" {
  type        = string
  description = "domain name from registrar"
}

variable "soa_email_entry" {
  type        = string
  description = "email of the domain soa"
}

variable "root_password" {
  type = string
  description = "root password for the vm"
}
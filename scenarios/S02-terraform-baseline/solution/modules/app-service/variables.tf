variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "app_service_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

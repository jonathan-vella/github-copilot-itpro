variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "server_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "aad_admin_login" {
  type        = string
  description = "The login username of the Azure AD Administrator of this SQL Server."
}

variable "aad_admin_object_id" {
  type        = string
  description = "The object id of the Azure AD Administrator of this SQL Server."
}

variable "aad_admin_tenant_id" {
  type        = string
  description = "The tenant id of the Azure AD Administrator of this SQL Server."
}

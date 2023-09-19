
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The location of the resource group"
}

variable "cluster_name" {
  type        = string
  description = "The name of the dluster(data-plane)"
}


variable "issuer_url" {
  type        = string
  description = "The issuer url of the cluster"
}

variable "main_storage_account_id" {
  type        = string
  description = "The name of the main storage account"
  default     = null
}
  
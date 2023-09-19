
variable "location" {
  type        = string
  description = "AKS region where cluster will be created"
}
variable "zones" {
  type        = string
  default     = "2"
  description = "AKS region where cluster and resources will be created"
}

variable "account_id" {
  description = "The ID of the account that will be created for IOMETE. This account will be used to create and manage your infrastructure. Please make sure you have valid account ID, otherwise the resource creation will fail."
  type        = string
}
variable "orchestrator_version" {
  description = "AKS kubernetes version"
  type        = string
  default     = "1.25.6"
}

variable "exec_max_count" {
  type        = number
  default     = 1000
  description = "Max. Node count for for lakehosue executer"
}

variable "exec_min_count" {
  type        = number
  default     = 1
  description = "Min. Node count for for lakehosue exec"

}

variable "driver_max_count" {
  type        = number
  default     = 100
  description = "Maximum Node count for for driver"
}

variable "driver_min_count" {
  type        = number
  default     = 1
  description = "Maximum Node count for for driver"

}

variable "system_vm_size" {
  type        = string
  default     = "Standard_D4as_v5"
  description = "Node size for for system"

}


variable "address_space" {
  type        = list(any)
  default     = ["10.8.0.0/16"]
  description = "Address space for the cluster network"
}

variable "cluster_subnet" {
  type        = list(any)
  default     = ["10.8.0.0/21"]
  description = "Subnet prefixes for the cluster network"
}

variable "service_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Service cidr for the cluster"
}

variable "dns_service_ip" {
  type        = string
  default     = "10.0.0.10"
  description = "DNS service ip for the cluster"
}
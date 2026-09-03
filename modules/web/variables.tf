variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for resource naming"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet used by the web tier"
  type        = string
}

variable "vm_size" {
  description = "SKU used by VM Scale Set instances"
  type        = string
}

variable "instance_count" {
  description = "Number of VM Scale Set instances"
  type        = number
}

variable "ssh_public_key" {
  description = "SSH public key used for VM administration"
  type        = string
}

variable "custom_data" {
  description = "cloud-init configuration used to bootstrap each instance"
  type        = string
}

variable "tags" {
  description = "Common tags applied to Azure resources"
  type        = map(string)
}
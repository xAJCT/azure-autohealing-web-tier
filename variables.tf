variable "project_name" {
  description = "Name used as the prefix for Azure resources"
  type        = string
  default     = "autoheal"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "Australia East"
}

variable "vm_size" {
  description = "Azure VM size used by the web tier"
  type        = string
  default     = "Standard_B1s"
}

variable "instance_count" {
  description = "Number of web server instances"
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count >= 2
    error_message = "The web tier must contain at least two VM instances."
  }
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used for VM administration"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
output "web_url" {
  description = "URL of the load-balanced NGINX web tier"
  value       = "http://${module.web.public_ip_address}"
}

output "public_ip_address" {
  description = "Public IP address of the Azure Load Balancer"
  value       = module.web.public_ip_address
}

output "vmss_name" {
  description = "Name of the Virtual Machine Scale Set"
  value       = module.web.vmss_name
}
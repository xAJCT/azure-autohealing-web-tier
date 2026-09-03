output "public_ip_address" {
  description = "Public IP address of the Azure Load Balancer"
  value       = azurerm_public_ip.web.ip_address
}

output "vmss_name" {
  description = "Name of the web Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.web.name
}

output "load_balancer_name" {
  description = "Name of the Azure Load Balancer"
  value       = azurerm_lb.web.name
}
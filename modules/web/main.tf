resource "azurerm_public_ip" "web" {
  name                = "${var.name_prefix}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_lb" "web" {
  name                = "${var.name_prefix}-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.web.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "web" {
  name            = "${var.name_prefix}-backend-pool"
  loadbalancer_id = azurerm_lb.web.id
}

resource "azurerm_lb_probe" "http" {
  name                = "http-health-probe"
  loadbalancer_id     = azurerm_lb.web.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "http" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.web.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.http.id
  disable_outbound_snat          = true
}

resource "azurerm_lb_outbound_rule" "web" {
  name                    = "web-outbound"
  loadbalancer_id         = azurerm_lb.web.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id

  frontend_ip_configuration {
    name = "public-frontend"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "web" {
  name                = "${var.name_prefix}-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku          = var.vm_size
  instances    = var.instance_count
  upgrade_mode = "Automatic"

  admin_username                  = "azureuser"
  disable_password_authentication = true

  health_probe_id = azurerm_lb_probe.http.id

  custom_data = base64encode(var.custom_data)

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "web-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web.id]
    }
  }

  automatic_instance_repair {
    enabled      = true
    grace_period = "PT10M"
  }

  lifecycle {
    ignore_changes = [instances]
  }

  tags = var.tags
}

resource "azurerm_monitor_autoscale_setting" "web" {
  name                = "${var.name_prefix}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.web.id
  enabled             = true

  profile {
    name = "maintain-capacity"

    capacity {
      default = var.instance_count
      minimum = var.instance_count
      maximum = var.instance_count
    }
  }

  tags = var.tags
}
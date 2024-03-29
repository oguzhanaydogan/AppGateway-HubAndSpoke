resource "azurerm_virtual_machine" "vm1" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resourcegroup
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = var.vm_size
  delete_os_disk_on_termination = var.delete_os_disk_on_termination
  delete_data_disks_on_termination = var.delete_data_disks_on_termination
  dynamic "identity" {
    for_each = var.identity_enabled ? [1] : []

    content {
      type         = var.vm_identity_type
    }
  }
 
  storage_image_reference {
    publisher = var.storage_image_reference_publisher
    offer     = var.storage_image_reference_offer
    sku       = var.storage_image_reference_sku
    version   = var.storage_image_reference_version
  }
  storage_os_disk {
    name              = var.storage_os_disk_name
    caching           = var.storage_os_disk_caching
    create_option     = var.storage_os_disk_create_option
    managed_disk_type = var.storage_os_disk_managed_disk_type
  }
  os_profile {
    computer_name  = var.vm_name
    admin_username = var.admin_username
    custom_data = file("${var.custom_data}")
    
  }
  os_profile_linux_config {
    disable_password_authentication = var.os_profile_linux_config_disable_password_authentication
        ssh_keys {
            path = "/home/${var.admin_username}/.ssh/authorized_keys"
            key_data = data.azurerm_ssh_public_key.ssh_public_key.public_key
    }
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resourcegroup

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = var.ip_configuration_subnet_id
    private_ip_address_allocation = var.ip_configuration_private_ip_address_allocation
    public_ip_address_id          = var.ip_configuration_public_ip_address_id
  }
}

data "azurerm_ssh_public_key" "ssh_public_key" {
  resource_group_name = var.ssh_key_rg
  name                = var.ssh_key_name
}

resource "azurerm_network_interface_security_group_association" "nic1" {
  count = var.nsg_association_enabled ? 1 : 0
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = var.nsg_id
}


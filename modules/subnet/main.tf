resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes

  lifecycle {
    ignore_changes = [ delegation[0].service_delegation[0].actions ]
  }
  dynamic "delegation" {
    for_each = var.delegation ? [1] : []
    content {
      name = "example-delegation"

      service_delegation {
          name    = var.delegation_name
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

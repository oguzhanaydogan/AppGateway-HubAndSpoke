resource "azurerm_firewall" "hub_firewall" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.sku_tier
  

  ip_configuration {
    name                 = "${var.name}-ip-configuration"
    subnet_id            = var.subnet_id  
  }
  management_ip_configuration {
    name = "${var.name}-management-ip-configuration"
    subnet_id = var.management_subnet_id
    public_ip_address_id = var.management_public_ip_address_id
  }
}
 
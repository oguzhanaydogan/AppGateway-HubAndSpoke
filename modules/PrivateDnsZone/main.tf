resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = var.name
  resource_group_name = var.resourcegroup
}

# Create azure private dns zone virtual network link for acr private endpoint vnet
# resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
#   for_each              = var.links
#   name                  = each.key
#   private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
#   resource_group_name   = var.resourcegroup
#   virtual_network_id    = each.value
# } 
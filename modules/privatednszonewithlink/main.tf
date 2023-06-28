resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = var.name
  resource_group_name =  var.resourcegroup
}

# Create azure private dns zone virtual network link for acr private endpoint vnet
resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  for_each = var.links
  name                  = each.value.link_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name   = each.value.resourcegroup
  virtual_network_id    = each.value.virtual_network_id
}
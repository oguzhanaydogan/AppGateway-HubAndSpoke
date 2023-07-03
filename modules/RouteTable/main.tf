resource "azurerm_route_table" "routetable" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "route" {
    for_each = var.route
    content {
        name                   = route.value.name
        address_prefix         = route.value.address_prefix
        next_hop_type          = route.value.next_hop_type
        next_hop_in_ip_address = route.value.next_hop_in_ip_address   
    }
  }
} 

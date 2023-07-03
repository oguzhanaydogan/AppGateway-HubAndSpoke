resource "azurerm_application_insights" "insight" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resourcegroup
  application_type    = var.application_type
} 
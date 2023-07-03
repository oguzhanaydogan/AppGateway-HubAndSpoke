resource "azurerm_role_assignment" "role_assignment" {
  scope              = var.scope_id
  principal_id       = var.principal_id
  role_definition_name = var.role_definition
}  
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = var.server_name
  resource_group_name    = var.resourcegroup
  location               = var.location
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  sku_name               = var.sku_name
  delegated_subnet_id    = var.delegated_subnet_id
  private_dns_zone_id    = var.private_dns_zone_id
  zone = var.zone
}

resource "azurerm_mysql_flexible_database" "db" {
  name                = var.db_name
  resource_group_name = var.resourcegroup
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = var.charset
  collation           = var.collation
}

resource "azurerm_mysql_flexible_server_configuration" "require-secure-transport" {
  name                = "${var.server_name}-require_secure_transport"
  resource_group_name = var.resourcegroup
  server_name         = azurerm_mysql_flexible_server.mysql.name
  value               = var.value
}

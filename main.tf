terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.61.0"
    }
  }

  # backend "azurerm" {
  #   resource_group_name  = "coy-backend"
  #   storage_account_name = "coystorage"
  #   container_name       = "terraformstate"
  #   key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

#RG##
module "resourcegroup" {
  source   = "./modules/ResourceGroup"
  location = var.location
  name     = var.resource_group_name
}

module "virtual_networks" {
  source              = "./modules/VirtualNetwork"
  for_each            = var.virtual_networks
  location            = module.resourcegroup.location
  resource_group_name = module.resourcegroup.name
  name                = each.value.name
  address_space       = each.value.address_space
}

module "subnets" {
  source               = "./modules/subnet"
  for_each             = var.subnets
  resource_group_name  = module.resourcegroup.name
  virtual_network_name = module.virtual_networks["${each.value.virtual_network_name}"].name
  subnet_name          = each.value.name
  address_prefixes     = each.value.address_prefixes
  delegation           = each.value.delegation
  delegation_name      = each.value.delegation_name
}

module "vnet_peerings" {
  source                    = "./modules/vnetpeering"
  for_each                  = var.vnet_peerings
  resource_group_name       = module.resourcegroup.name
  name                      = each.value.name
  virtual_network_name      = module.virtual_networks["${each.value.virtual_network}"].name
  remote_virtual_network_id = module.virtual_networks["${each.value.remote_virtual_network}"].id
}



module "route_tables" {
  source              = "./modules/RouteTable"
  for_each            = var.route_tables
  resource_group_name = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = each.value.name
  route               = each.value.routes
  subnet_id           = module.subnets["${each.value.subnet_name}"].id
}

module "subnet_route_table_associations" {
  source         = "./modules/RouteTableExtraAssociation"
  for_each       = var.subnet_route_table_associations
  subnet_id      = module.subnets["${each.value.subnet}"].id
  route_table_id = module.route_tables["${each.value.route_table}"].id
}

module "public_ip_addresses" {
  source              = "./modules/PublicIPAddress"
  for_each            = var.public_ip_addresses
  resource_group_name = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = each.value.name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
}

module "firewalls" {
  source               = "./modules/AzureFirewall"
  for_each             = var.firewalls
  location             = module.resourcegroup.location
  resource_group_name  = module.resourcegroup.name
  name                 = each.value.name
  sku_tier             = each.value.sku_tier
  subnet_id            = module.subnets["${each.value.subnet}"].id
  public_ip_address_id = module.public_ip_addresses["${each.value.public_ip_address}"].id
}

module "firewall_network_rule_collections" {
  source                 = "./modules/AzureFirewallNetworkRuleCollection"
  for_each               = var.firewall_network_rule_collections
  resource_group_name    = module.resourcegroup.name
  name                   = each.value.name
  firewall               = module.firewalls["${each.value.firewall}"].name
  priority               = each.value.priority
  action                 = each.value.action
  firewall_network_rules = each.value.firewall_network_rules
}

module "app_service_plans" {
  source              = "./modules/AppServicePlan"
  for_each            = var.app_service_plans
  resource_group_name = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = each.value.name
  os_type             = each.value.os_type
  sku_name            = each.value.sku_name
}
data "azurerm_key_vault" "example" {
  name                = "keyvault-coy"
  resource_group_name = "ssh"
}

data "azurerm_client_config" "current" {}

module "key_vault_access_policies" {
  source                   = "./modules/KeyVaultAccessPolicy"
  for_each                 = var.key_vault_access_policies
  key_vault                = each.value.key_vault
  key_vault_resource_group = each.value.key_vault_resource_group
  key_permissions          = each.value.key_permissions
  secret_permissions       = each.value.secret_permissions
  object_id                = data.azurerm_client_config.current.object_id
}

module "key_vault_access_policies2" {
  source                   = "./modules/KeyVaultAccessPolicy"
  for_each                 = var.key_vault_access_policies_02
  key_vault                = each.value.key_vault
  key_vault_resource_group = each.value.key_vault_resource_group
  key_permissions          = each.value.key_permissions
  secret_permissions       = each.value.secret_permissions
  object_id                = local.resources["${each.value.key_vault_access_owner}"].principal_id
}


# local.resources["${each.value.key_vault_access_owner}"]
module "key_vault_secrets" {
  source                   = "./modules/KeyVaultSecret"
  for_each                 = var.key_vault_secrets
  key_vault                = each.value.key_vault
  key_vault_resource_group = each.value.key_vault_resource_group
  secret                   = each.value.secret
  depends_on               = [module.key_vault_access_policies]
}

module "acrs" {
  source                        = "./modules/AzureContainerRegistry"
  for_each                      = var.acrs
  name                          = each.value.name
  resource_group_name           = module.resourcegroup.name
  location                      = module.resourcegroup.location
  admin_enabled                 = each.value.admin_enabled
  sku                           = each.value.sku
  public_network_access_enabled = each.value.public_network_access_enabled
  network_rule_bypass_option    = each.value.network_rule_bypass_option
}

module "network_security_groups" {
  source         = "./modules/NetworkSecurityGroup"
  for_each       = var.network_security_groups
  location       = module.resourcegroup.location
  resourcegroup  = module.resourcegroup.name
  name           = each.value.name
  security_rules = each.value.security_rules
}

module "linux_virtual_machines" {
  source                                                  = "./modules/VirtualMachine"
  for_each                                                = var.linux_virtual_machines
  location                                                = module.resourcegroup.location
  resourcegroup                                           = module.resourcegroup.name
  vm_name                                                 = each.value.vm_name
  vm_size                                                 = each.value.vm_size
  delete_os_disk_on_termination                           = each.value.delete_os_disk_on_termination
  delete_data_disks_on_termination                        = each.value.delete_data_disks_on_termination
  identity_enabled                                        = each.value.identity_enabled
  vm_identity_type                                        = each.value.vm_identity_type
  storage_image_reference_publisher                       = each.value.storage_image_reference_publisher
  storage_image_reference_offer                           = each.value.storage_image_reference_offer
  storage_image_reference_sku                             = each.value.storage_image_reference_sku
  storage_image_reference_version                         = each.value.storage_image_reference_version
  storage_os_disk_name                                    = each.value.storage_os_disk_name
  storage_os_disk_caching                                 = each.value.storage_os_disk_caching
  storage_os_disk_create_option                           = each.value.storage_os_disk_create_option
  storage_os_disk_managed_disk_type                       = each.value.storage_os_disk_managed_disk_type
  admin_username                                          = each.value.admin_username
  custom_data                                             = each.value.custom_data
  os_profile_linux_config_disable_password_authentication = each.value.os_profile_linux_config_disable_password_authentication
  ip_configuration_name                                   = each.value.ip_configuration_name
  ip_configuration_subnet_id                              = module.subnets["${each.value.ip_configuration_subnet}"].id
  ip_configuration_private_ip_address_allocation          = each.value.ip_configuration_private_ip_address_allocation
  ip_configuration_public_ip_address_id                   = module.public_ip_addresses["${each.value.ip_configuration_public_ip_address}"].id
  ssh_key_rg                                              = each.value.ssh_key_rg
  ssh_key_name                                            = each.value.ssh_key_name
  nsg_association_enabled                                 = each.value.nsg_association_enabled
  nsg_id                                                  = module.network_security_groups["${each.value.nsg}"].id
}

module "private_dns_zones" {
  source             = "./modules/PrivateDnsZoneWithLink"
  for_each           = var.private_dns_zones
  resourcegroup      = module.resourcegroup.name
  virtual_network_id = module.virtual_networks["${each.value.virtual_network}"].id
  link_name          = each.value.link_name
  name               = each.value.dns_zone_name
}

module "private_dns_zone_extra_links" {
  source                = "./modules/PrivateDnsZoneExtraLink"
  for_each              = var.private_dns_zone_extra_links
  resourcegroup         = module.resourcegroup.name
  name                  = each.value.link_name
  virtual_network_id    = module.virtual_networks["${each.value.virtual_network}"].id
  private_dns_zone_name = module.private_dns_zones["${each.value.private_dns_zone}"].name
}

module "mysql_databases" {
  source              = "./modules/MySql"
  for_each            = var.mysql_databases
  location            = module.resourcegroup.location
  resourcegroup       = module.resourcegroup.name
  server_name         = each.value.server_name
  db_name             = each.value.db_name
  admin_username      = each.value.admin_username
  admin_password      = module.key_vault_secrets["${each.value.admin_password_secret}"].value
  delegated_subnet_id = module.subnets["${each.value.delegated_subnet}"].id
  private_dns_zone_id = module.private_dns_zones["${each.value.private_dns_zone}"].id
  zone                = each.value.zone
}

module "application_insights" {
  source           = "./modules/ApplicationInsight"
  for_each         = var.application_insights
  name             = each.value.name
  location         = module.resourcegroup.location
  resourcegroup    = module.resourcegroup.name
  application_type = each.value.application_type
}

module "app_services" {
  source   = "./modules/AppService"
  for_each = var.app_services

  resource_group_name     = module.resourcegroup.name
  location                = module.resourcegroup.location
  name                    = each.value.name
  service_plan_id         = module.app_service_plans["${each.value.app_service_plan}"].id
  vnet_integration_subnet = module.subnets["${each.value.vnet_integration_subnet}"].id
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY             = each.value.application_insights_enabled ? module.application_insights["${each.value.application_insight}"].instrumentation_key : ""
    APPLICATIONINSIGHTS_CONNECTION_STRING      = each.value.application_insights_enabled ? module.application_insights["${each.value.application_insight}"].connection_string : ""
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    "MYSQL_PASSWORD"                           = "@Microsoft.KeyVault(SecretUri=${module.key_vault_secrets["${each.value.mysql_password_secret}"].id})"
    "MYSQL_DATABASE_HOST"                      = module.mysql_databases["${each.value.mysql_database}"].host
    "MYSQL_DATABASE"                           = module.mysql_databases["${each.value.mysql_database}"].database_name
    "MYSQL_USER"                               = module.mysql_databases["${each.value.mysql_database}"].database_username
    "DOCKER_REGISTRY_SERVER_URL"               = module.acrs["${each.value.acr}"].fqdn
    "WEBSITE_PULL_IMAGE_OVER_VNET"             = true
  }
}

module "private_endpoints" {
  source                 = "./modules/privateendpoint"
  for_each               = var.private_endpoints
  resourcegroup          = module.resourcegroup.name
  location               = module.resourcegroup.location
  subnet_id              = module.subnets["${each.value.subnet}"].id
  private_dns_zone_ids   = [module.private_dns_zones["${each.value.private_dns_zone}"].id]
  attached_resource_name = each.value.attached_resource_name
  attached_resource_id   = local.resources[each.value.attached_resource].id
  subresource_name       = each.value.subresource_name
}

module "role_assignments"{
  source = "./modules/RoleAssignment"
  for_each = var.role_assignments
  scope = local.resources["${each.value.scope}"].id
  principal_id = local.resources["${each.value.role_owner}"].principal_id
  role_definition = each.value.role_definition
}

module "application_gateways" {
  source = "./modules/ApplicationGateway"
  for_each = var.application_gateways
  resourcegroup = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = each.value.name
  sku_name = each.value.sku_name
  sku_tier = each.value.sku_tier
  sku_capacity =each.value.sku_capacity
  gateway_ip_configuration_name = each.value.gateway_ip_configuration_name
  gateway_ip_configuration_subnet_id = module.subnets["${each.value.gateway_ip_configuration_subnet}"].id
  frontend_port_name = each.value.frontend_port_name
  frontend_port_port = each.value.frontend_port_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  frontend_ip_configuration_public_ip_address_id = module.public_ip_addresses["${each.value.frontend_ip_configuration_public_ip_address}"].id
  # backend_address_pools = local.backend_address_pools_fqdns[each.value.index]
  backend_address_pools = local.backend_address_pools
  backend_http_settingses = each.value.backend_http_settingses
  probes = each.value.probes
  http_listener_frontend_port_name = each.value.http_listener_frontend_port_name
  http_listener_name = each.value.http_listener_name
  http_listener_frontend_ip_configuration_name = each.value.http_listener_frontend_ip_configuration_name
  http_listener_protocol = each.value.http_listener_protocol
  request_routing_rule_name = each.value.request_routing_rule_name
  request_routing_rule_rule_type = each.value.request_routing_rule_rule_type
  request_routing_rule_http_listener_name = each.value.request_routing_rule_http_listener_name
  request_routing_rule_backend_address_pool_name = each.value.request_routing_rule_backend_address_pool_name
  request_routing_rule_backend_http_settings_name = each.value.request_routing_rule_backend_http_settings_name
  request_routing_rule_url_path_map_name = each.value.request_routing_rule_url_path_map_name
  request_routing_rule_priority = each.value.request_routing_rule_priority
  url_path_map_name = each.value.url_path_map_name
  url_path_map_default_backend_http_settings_name = each.value.url_path_map_default_backend_http_settings_name
  url_path_map_default_backend_address_pool_name = each.value.url_path_map_default_backend_address_pool_name
  url_path_map_path_rules = each.value.url_path_map_path_rules
}

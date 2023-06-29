locals {
  resources = {
    acr_01                   = module.acrs["acr_01"]
    app_service_01           = module.app_services["app_service_01"]
    app_service_02           = module.app_services["app_service_02"]
    linux_virtual_machine_01 = module.linux_virtual_machines["linux_virtual_machine_01"]
    vnet_acr                 = module.virtual_networks["vnet_acr"]
    vnet_app                 = module.virtual_networks["vnet_app"]
    vnet_hub                 = module.virtual_networks["vnet_hub"]
    vnet_db                  = module.virtual_networks["vnet_db"]
    route_table_01           = module.route_tables["route_table_01"]
    vnet_acr_subnet_acr      = module.subnets["vnet_acr_subnet_acr"]
    vnet_db_subnet_db        = module.subnets["vnet_db_subnet_db"]
  }

  private_dns_zone_links = {
    for k, v in var.private_dns_zones : k => {
      for link in v.links : link.link_name => local.resources[link.virtual_network].id
    }
  }
  
  backend_address_pools = {
    for k, v in var.application_gateways : k => {
      for pool in v.backend_address_pools : pool.name => [
          for resource in pool.resources : local.resources[resource].fqdn
      ]
    }
  }

  route_table_associations = {
    for k, v in var.route_tables : k => {
      for assoc in v.route_table_associations : local.resources[assoc.route_table].id => local.resources[assoc.subnet].id
    }
  }
}




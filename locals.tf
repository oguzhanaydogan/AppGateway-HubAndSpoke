locals {
  resources = {
    acr_01                   = module.acrs["acr_01"]
    app_service_01           = module.app_services["app_service_01"]
    app_service_02           = module.app_services["app_service_02"]
    linux_virtual_machine_01 = module.linux_virtual_machines["linux_virtual_machine_01"]
  }

  # private_dns_zones_virtual_network_links = {
  #   for k, v in var.private_dns_zones : k => {
  #     for link in v.links : link.link_name => module.virtual_networks[link.virtual_network].id
  #   }
  # }

  backend_address_pools = {
    for k, v in var.application_gateways : k => {
      for pool in v.backend_address_pools : pool.name => [
        for resource in pool.resources : local.resources[resource].fqdn
      ]
    }
  }

  # route_table_associations = {
  #   for k, assoc in var.route_table_associations : k => {
  #     route_table_id = module.route_tables[assoc.route_table].id
  #     subnet_id = module.subnets[assoc.subnet].id
  #   }
  # }
}



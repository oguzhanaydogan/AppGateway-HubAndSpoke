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
  }

  private_dns_zone_links = {
    for k, v in var.private_dns_zones : k => [
      for link in v.links : {
        name               = link.link_name
        virtual_network_id = local.resources[link.virtual_network].id
      }
    ]
  }

  backend_address_pools = {
    for k, v in var.application_gateways : k => [
      for pool in v.backend_address_pools : {
        name = pool.name
        fqdns = [
          for resource in pool.resources : local.resources[resource].fqdn
        ]
      }
    ]
  }
}




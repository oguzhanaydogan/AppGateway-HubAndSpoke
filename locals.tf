locals {
  resources = {
    app_service_01 = module.app_services["app_service_01"]
    app_service_02 = module.app_services["app_service_02"]
    linux_virtual_machine_01 = module.linux_virtual_machines["linux_virtual_machine_01"]
    acr_01 = module.acrs["acr_01"]
  }

  backend_address_pools = {
    for k, v in var.application_gateways: k => [
      for pool in v.backend_address_pools: {
        name = pool.name
        fqdns = [
          for resource in pool.resources: local.resources[resource].fqdn
        ]
      }
    ]
  }
}




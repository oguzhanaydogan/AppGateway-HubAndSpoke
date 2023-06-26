locals {
    resources = {
    app_service_01 = module.app_services["app_service_01"]
    app_service_02 = module.app_services["app_service_02"]
    linux_virtual_machine_01 = module.linux_virtual_machines["linux_virtual_machine_01"]
    acr_01 = module.acrs["acr_01"]
  }

  backend_address_pools = [
    for x in var.application_gateways: x.backend_address_pools
  ]

  backend_address_pools_fqdns = [
    for b in backend_address_pools: b.name => {
      name = b.name
      fqdns = [
        for fqdn in b.fqdns : local.resources[b].fqdn
      ]
    }
  ]
  

  for_each = { for pool in var.backend_address_pools : pool.name => pool }

  name  = each.value.name
  fqdns = each.value.fqdns
    
  #       {
  #         name = "apps-backend-pool"
  #         fqdns = [
  #           local.resources["app_service_01"].fqdn,
  #           local.resources["app_service_02"].fqdn
  #         ]
  #       },
  #       {
  #         name = "app1-backend-pool"
  #         fqdns = [
  #           local.resources["app_service_01"].fqdn
  #         ]
  #       },
  #       {
  #         name = "app2-backend-pool"
  #         fqdns = [
  #           local.resources["app_service_02"].fqdn
  #         ]
  #       }

}




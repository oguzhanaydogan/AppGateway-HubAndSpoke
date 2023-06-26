locals {
    resources = {
    app_service_01 = module.app_services["app_service_01"]
    app_service_02 = module.app_services["app_service_02"]
    linux_virtual_machine_01 = module.linux_virtual_machines["linux_virtual_machine_01"]
    acr_01 = module.acrs["acr_01"]

  }



  backend_address_pools = [
        {
          name = "apps-backend-pool"
          fqdns = [
            module.app_services["app_service_01"].fqdn,

            module.app_services["app_service_02"].fqdn
          ]
        },
        {
          name = "app1-backend-pool"
          fqdns = [
            module.app_services["app_service_01"].fqdn
          ]
        },
        {
          name = "app2-backend-pool"
          fqdns = [
            module.app_services["app_service_02"].fqdn
          ]
        }
      ]

  backend_address_pools_fqdns = [
    [
      module.app_services["app_service_01"].fqdn,
      module.app_services["app_service_02"].fqdn
    ],
    [
      module.app_services["app_service_01"].fqdn
    ],
    [
      module.app_services["app_service_02"].fqdn
    ]
  ]

  # role_assignments = [
    # {
    #   scope           = module.acrs["acr_01"].id
    #   principal_id    = module.app_services["app_service_01"].principal_id
    #   role_definition = "AcrPull"
    # # },
    # {
    #   scope           = module.acrs["acr_01"].id
    #   principal_id    = module.app_services["app_service_02"].principal_id
    #   role_definition = "AcrPull"
    # },
    # {
    #   scope           = module.acrs["acr_01"].id
    #   principal_id    = module.app_services["app_service_01"].principal_id
    #   role_definition = "AcrPull"
    # },
    # {
    #   scope           = module.acrs["acr_01"].id
    #   principal_id    = module.linux_virtual_machines["linux_virtual_machine_01"].principal_id
    #   role_definition = "AcrPush"
    # },
    # {
    #   scope           = module.app_services["app_service_01"].id
    #   principal_id    = module.linux_virtual_machines["linux_virtual_machine_01"].principal_id
    #   role_definition = "Contributor"
    # },
  #   {
  #     scope           = module.app_services["app_service_02"].id
  #     principal_id    = module.linux_virtual_machines["linux_virtual_machine_01"].principal_id
  #     role_definition = "Contributor"
  #   }
  # ]

  # attached_resource_ids = [
  #   module.acrs["acr_01"].id,
  #   module.app_services["app_service_01"].id,
  #   module.app_services["app_service_02"].id
  # ]
}




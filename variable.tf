variable "location" {
  default = "eastus"
}

variable "resource_groups" {
  default = {
    resource_group_01 = {
      location = "East Us"
      name     = "CoyResourceGroup"
    }
  }
}

variable "virtual_networks" {
  default = {
    vnet_app = {
      name                = "app-network"
      address_space       = ["10.0.0.0/16"]
      resource_group_name = "resource_group_01"
    }
    vnet_acr = {
      name                = "acr-network"
      address_space       = ["10.1.0.0/16"]
      resource_group_name = "resource_group_01"
    }
    vnet_hub = {
      name                = "hub-network"
      address_space       = ["10.3.0.0/16"]
      resource_group_name = "resource_group_01"
    }
    vnet_db = {
      name                = "db-network"
      address_space       = ["10.2.0.0/16"]
      resource_group_name = "resource_group_01"
    }
  }
}

variable "subnets" {
  default = {

    ### APP VNET SUBNETS
    vnet_app_subnet_app = {
      name                 = "app-subnet"
      address_prefixes     = ["10.0.1.0/24"]
      delegation           = true
      delegation_name      = "Microsoft.Web/serverFarms"
      virtual_network_name = "vnet_app"
      resource_group_name  = "resource_group_01"
    }
    vnet_app_subnet_default = {
      name                 = "default_subnet"
      address_prefixes     = ["10.0.0.0/24"]
      delegation           = false
      delegation_name      = ""
      virtual_network_name = "vnet_app"
      resource_group_name  = "resource_group_01"
    }
    vnet_app_subnet_appgateway = {
      name                 = "appgateway_subnet"
      address_prefixes     = ["10.0.4.0/24"]
      delegation           = false
      delegation_name      = ""
      virtual_network_name = "vnet_app"
      resource_group_name  = "resource_group_01"
    }
    vnet_app_subnet_app1endpoint = {
      name                 = "app1endpoint_subnet"
      address_prefixes     = ["10.0.5.0/26"]
      delegation           = false
      delegation_name      = ""
      virtual_network_name = "vnet_app"
      resource_group_name  = "resource_group_01"
    }
    vnet_app_subnet_app2endpoint = {
      name                 = "app2endpoint_subnet"
      address_prefixes     = ["10.0.5.64/26"]
      delegation           = false
      delegation_name      = ""
      virtual_network_name = "vnet_app"
      resource_group_name  = "resource_group_01"
    }


    ### ACR VNET SUBNETS

    vnet_acr_subnet_acr = {
      name                 = "acr-subnet"
      address_prefixes     = ["10.1.0.0/24"]
      delegation           = false
      delegation_name      = ""
      virtual_network_name = "vnet_acr"
      resource_group_name  = "resource_group_01"
    }

    ### HUB VNET SUBNETS

    vnet_hub_subnet_default = {
      name                 = "default-subnet"
      address_prefixes     = ["10.3.0.0/24"]
      delegation           = false
      delegation_name      = ""
      virtual_network_name = "vnet_hub"
      resource_group_name  = "resource_group_01"
    }

    vnet_hub_subnet_firewall = {
      name                 = "AzureFirewallSubnet"
      address_prefixes     = ["10.3.1.0/26"]
      delegation           = false
      delegation_name      = ""
      virtual_network_name = "vnet_hub"
      resource_group_name  = "resource_group_01"
    }

    ### DB VNET SUBNETS

    vnet_db_subnet_db = {
      name                 = "mysql-subnet"
      address_prefixes     = ["10.2.1.0/26"]
      delegation           = true
      delegation_name      = "Microsoft.DBforMySQL/flexibleServers"
      virtual_network_name = "vnet_db"
      resource_group_name  = "resource_group_01"
    }
  }
}

### VNET PEERINGS
variable "vnet_peerings" {
  default = {
    db_to_hub = {
      name                   = "db-hub"
      virtual_network        = "vnet_db"
      remote_virtual_network = "vnet_hub"
      resource_group_name    = "resource_group_01"
    }

    hub_to_db = {
      name                   = "hub-db"
      virtual_network        = "vnet_hub"
      remote_virtual_network = "vnet_db"
      resource_group_name    = "resource_group_01"
    }

    app_to_hub = {
      name                   = "app-hub"
      virtual_network        = "vnet_app"
      remote_virtual_network = "vnet_hub"
      resource_group_name    = "resource_group_01"
    }

    hub_to_app = {
      name                   = "hub-app"
      virtual_network        = "vnet_hub"
      remote_virtual_network = "vnet_app"
      resource_group_name    = "resource_group_01"
    }

    acr_to_hub = {
      name                   = "acr-hub"
      virtual_network        = "vnet_acr"
      remote_virtual_network = "vnet_hub"
      resource_group_name    = "resource_group_01"
    }

    hub_to_acr = {
      name                   = "hub-acr"
      virtual_network        = "vnet_hub"
      remote_virtual_network = "vnet_acr"
      resource_group_name    = "resource_group_01"
    }
  }
}

### route tables
variable "route_tables" {
  default = {
    route_table_01 = {
      name                = "route-table-01"
      subnet_name         = "vnet_app_subnet_app"
      resource_group_name = "resource_group_01"
      routes = {
        webapp-acr-allow = {
          name                   = "webapp-acr-allow"
          address_prefix         = "10.1.0.0/24"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.3.1.4"
        }
        webapp-db-allow = {
          name                   = "webapp-db-allow"
          address_prefix         = "10.2.1.0/26"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.3.1.4"
        }
        db-webapp-allow = {
          name                   = "db-webapp-allow"
          address_prefix         = "10.0.1.0/24"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.3.1.4"
        }
      }
    }
  }
}

variable "subnet_route_table_associations" {
  default = {
    route_01_vnet_acr_subnet_acr = {
      subnet      = "vnet_acr_subnet_acr"
      route_table = "route_table_01"
    }
    route_01_vnet_db_subnet_db = {
      subnet      = "vnet_db_subnet_db"
      route_table = "route_table_01"
    }
  }
}

variable "public_ip_addresses" {
  default = {
    public_ip_firewall_hub = {
      name                = "public_ip_firewall_hub"
      allocation_method   = "Static"
      sku                 = "Standard"
      resource_group_name = "resource_group_01"
    }
    public_ip_app_gateway = {
      name                = "PublicFrontendIpIPv4"
      allocation_method   = "Static"
      sku                 = "Standard"
      resource_group_name = "resource_group_01"
    }
    public_ip_virtual_machine_01 = {
      name                = "public-ip-vm-custom-agent"
      allocation_method   = "Static"
      sku                 = "Standard"
      resource_group_name = "resource_group_01"

    }
  }
}

variable "firewalls" {
  default = {
    firewall_hub = {
      name                  = "firewall-hub"
      sku_tier              = "Premium"
      ip_configuration_name = "configuration"
      subnet                = "vnet_hub_subnet_firewall"
      public_ip_address     = "public_ip_firewall_hub"
      resource_group_name   = "resource_group_01"
    }
  }
}

variable "firewall_network_rule_collections" {
  default = {
    firewall_network_rule_collection_01 = {
      name                = "firewall_hub"
      firewall            = "firewall_hub"
      priority            = 100
      action              = "Allow"
      resource_group_name = "resource_group_01"
      firewall_network_rules = {
        "webapp-acr-rule" = {
          source_addresses      = ["10.0.1.0/24"]
          destination_ports     = ["*"]
          destination_addresses = ["10.1.0.0/24"]
          protocols             = ["Any"]
        }
        "webapp-db-rule" = {
          source_addresses      = ["10.0.1.0/24"]
          destination_ports     = ["*"]
          destination_addresses = ["10.2.1.0/26"]
          protocols             = ["Any"]
        }
        "customagent-acr-rule" = {
          source_addresses      = ["10.1.0.4/32"]
          destination_ports     = ["*"]
          destination_addresses = ["10.1.0.0/24"]
          protocols             = ["Any"]
        }
        "acr-webapp-rule" = {
          source_addresses      = ["10.1.0.0/24"]
          destination_ports     = ["*"]
          destination_addresses = ["10.0.1.0/24"]
          protocols             = ["Any"]
        }
      }
    }
  }
}

variable "app_service_plans" {
  default = {
    app_service_plan_coy_phonebook = {
      name                = "coyphonebook"
      os_type             = "Linux"
      sku_name            = "P1v2"
      resource_group_name = "resource_group_01"
    }
  }
}

variable "app_services" {
  default = {
    app_service_01 = {
      name                         = "coywebapp-1"
      app_service_plan             = "app_service_plan_coy_phonebook"
      mysql_password_secret        = "key_vault_secret_mysql_password"
      application_insights_enabled = true
      vnet_integration_subnet      = "vnet_app_subnet_app"
      mysql_database               = "mysql_database_01"
      acr                          = "acr_01"
      application_insight          = "application_insight_01"
      resource_group_name          = "resource_group_01"
    }
    app_service_02 = {
      name                         = "coywebapp-2"
      app_service_plan             = "app_service_plan_coy_phonebook"
      mysql_password_secret        = "key_vault_secret_mysql_password"
      application_insights_enabled = false
      vnet_integration_subnet      = "vnet_app_subnet_app"
      mysql_database               = "mysql_database_01"
      acr                          = "acr_01"
      resource_group_name          = "resource_group_01"
    }
  }
}


variable "key_vault_secrets" {
  default = {
    key_vault_secret_mysql_password = {
      key_vault                = "keyvault-coy"
      key_vault_resource_group = "ssh"
      secret                   = "MYSQLPASSWORD"
    }
  }
}

variable "key_vault_access_policies" {
  default = {
    key_vault_access_policy_coy_vault = {
      key_vault                = "keyvault-coy"
      key_vault_resource_group = "ssh"
      key_vault_access_owner   = "client_config"
      key_permissions = [
        "Get", "List",
      ]
      secret_permissions = [
        "Get", "List",
      ]
    }
  }
}

variable "key_vault_access_policies_02" {
  default = {
    key_vault_access_policy_coy_vault_02 = {
      key_vault                = "keyvault-coy"
      key_vault_resource_group = "ssh"
      key_vault_access_owner   = "app_service_01"

      key_permissions = [
        "Get", "List",
      ]
      secret_permissions = [
        "Get", "List",
      ]
    }
    key_vault_access_policy_coy_vault_03 = {
      key_vault                = "keyvault-coy"
      key_vault_resource_group = "ssh"
      key_vault_access_owner   = "app_service_02"
      key_permissions = [
        "Get", "List",
      ]
      secret_permissions = [
        "Get", "List",
      ]
    }
  }
}

variable "acrs" {
  default = {
    acr_01 = {
      name                          = "coyhub"
      sku                           = "Premium"
      admin_enabled                 = false
      public_network_access_enabled = false
      network_rule_bypass_option    = "None"
      resource_group_name           = "resource_group_01"
    }
  }
}

variable "private_dns_zones" {
  default = {
    private_dns_zone_acr = {
      resource_group_name = "resource_group_01"
      dns_zone_name = "privatelink.azurecr.io"
      link_name = "private-dns-zone-acr-link-vnet-acr"
      virtual_network = "vnet_acr"
    }
    private_dns_zone_app = {
      dns_zone_name       = "privatelink.azurewebsites.net"
      resource_group_name = "resource_group_01"
          link_name       = "private-dns-zone-app-link-vnet-app"
          virtual_network = "vnet_app"
    }
    private_dns_zone_mysql = {
      dns_zone_name       = "privatelink.mysql.database.azure.com"
      resource_group_name = "resource_group_01"
          link_name       = "private-dns-zone-mysql-link-vnet-db"
          virtual_network = "vnet_db"
    }
  }
}

variable "private_dns_zone_extra_links" {
  default = {
    private_dns_zone_acr_link_vnet_app = {
      link_name        = "private-dns-zone-acr-link-vnet-app"
      virtual_network  = "vnet_app"
      private_dns_zone = "private_dns_zone_acr"
      resource_group_name = "resource_group_01"
    }

    private_dns_zone_acr_link_vnet_hub = {
      link_name        = "private-dns-zone-acr-link-vnet-hub"
      virtual_network  = "vnet_hub"
      private_dns_zone = "private_dns_zone_acr"
      resource_group_name = "resource_group_01"
    }

    private_dns_zone_mysql_link_vnet_app = {
      link_name        = "private-dns-zone-mysql-link-vnet-app"
      virtual_network  = "vnet_app"
      private_dns_zone = "private_dns_zone_mysql"
      resource_group_name = "resource_group_01"
    }

    private_dns_zone_db_link_vnet_hub = {
      link_name        = "private-dns-zone-mysql-link-vnet-hub"
      virtual_network  = "vnet_hub"
      private_dns_zone = "private_dns_zone_mysql"
      resource_group_name = "resource_group_01"
    }
  }
}

# variable "private_dns_zones" {
#   default = {
#     private_dns_zone_acr = {
#       dns_zone_name       = "privatelink.azurecr.io"
#       resource_group_name = "resource_group_01"
#       links = [
#         {
#           link_name       = "private-dns-zone-acr-link-vnet-acr"
#           virtual_network = "vnet_acr"
#         },
#         {
#           link_name       = "private-dns-zone-acr-link-vnet-app"
#           virtual_network = "vnet_app"
#         },
#         {
#           link_name       = "private-dns-zone-acr-link-vnet-hub"
#           virtual_network = "vnet_hub"
#         }
#       ]
#     }
#     private_dns_zone_app = {
#       dns_zone_name       = "privatelink.azurewebsites.net"
#       resource_group_name = "resource_group_01"
#       links = [
#         {
#           link_name       = "private-dns-zone-app-link-vnet-app"
#           virtual_network = "vnet_app"
#         }
#       ]
#     }
#     private_dns_zone_mysql = {
#       dns_zone_name       = "privatelink.mysql.database.azure.com"
#       resource_group_name = "resource_group_01"
#       links = [
#         {
#           link_name       = "private-dns-zone-mysql-link-vnet-db"
#           virtual_network = "vnet_db"
#         },
#         {
#           link_name       = "private-dns-zone-mysql-link-vnet-app"
#           virtual_network = "vnet_app"
#         },
#         {
#           link_name       = "private-dns-zone-mysql-link-vnet-hub"
#           virtual_network = "vnet_hub"
#         }
#       ]
#     }
#   }
# }

variable "private_endpoints" {
  default = {
    private_endpoint_acr = {
      attached_resource_name = "coyhub"
      private_dns_zone       = "private_dns_zone_acr"
      subresource_name       = "registry"
      subnet                 = "vnet_acr_subnet_acr"
      resource_group_name    = "resource_group_01"
      attached_resource      = "acr_01"
    }
    private_endpoint_app1 = {
      attached_resource_name = "app_service_01"
      private_dns_zone       = "private_dns_zone_app"
      subresource_name       = "sites"
      subnet                 = "vnet_app_subnet_app1endpoint"
      resource_group_name    = "resource_group_01"
      attached_resource      = "app_service_01"
    }
    private_endpoint_app2 = {
      attached_resource_name = "app_service_02"
      private_dns_zone       = "private_dns_zone_app"
      subresource_name       = "sites"
      subnet                 = "vnet_app_subnet_app2endpoint"
      resource_group_name    = "resource_group_01"
      attached_resource      = "app_service_02"
    }
  }
}

variable "linux_virtual_machines" {
  default = {
    linux_virtual_machine_01 = {
      resource_group_name                                     = "resource_group_01"
      vm_name                                                 = "vm-custom-agent"
      vm_size                                                 = "Standard_D2s_v3"
      delete_data_disks_on_termination                        = true
      delete_os_disk_on_termination                           = true
      identity_enabled                                        = true
      vm_identity_type                                        = "SystemAssigned"
      storage_image_reference_publisher                       = "Canonical"
      storage_image_reference_offer                           = "UbuntuServer"
      storage_image_reference_sku                             = "18.04-LTS"
      storage_image_reference_version                         = "latest"
      storage_os_disk_name                                    = "myosdisk1"
      storage_os_disk_caching                                 = "ReadWrite"
      storage_os_disk_create_option                           = "FromImage"
      storage_os_disk_managed_disk_type                       = "Standard_LRS"
      admin_username                                          = "azureuser"
      custom_data                                             = "/modules/VirtualMachine/vm-custom-agent.sh"
      os_profile_linux_config_disable_password_authentication = true
      ip_configuration_name                                   = "testconfiguration1"
      ip_configuration_subnet                                 = "vnet_acr_subnet_acr"
      ip_configuration_private_ip_address_allocation          = "Dynamic"
      ip_configuration_public_ip_address                      = "public_ip_virtual_machine_01"
      ssh_key_rg                                              = "ssh"
      ssh_key_name                                            = "azuresshhakan"
      nsg_association_enabled                                 = true
      nsg                                                     = "nsg_01"
    }
  }
}

variable "network_security_groups" {
  default = {
    nsg_01 = {
      name                = "nsg-01"
      resource_group_name = "resource_group_01"
      security_rules = {
        allowssh = {
          name                       = "AllowSSH"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    }
  }
}

variable "mysql_databases" {
  default = {

    mysql_database_01 = {
      resource_group_name   = "resource_group_01"
      server_name           = "coy-database-server2"
      db_name               = "phonebook"
      admin_username        = "coyadmin"
      admin_password_secret = "key_vault_secret_mysql_password"
      delegated_subnet      = "vnet_db_subnet_db"
      private_dns_zone      = "private_dns_zone_mysql"
      zone                  = "1"
      sku_name              = "B_Standard_B1s"
      charset               = "utf8"
      collation             = "utf8_unicode_ci"
      value                 = "OFF"
    }
  }
}

variable "application_insights" {
  default = {
    application_insight_01 = {
      name                = "application-insight-01"
      application_type    = "web"
      resource_group_name = "resource_group_01"
    }
  }
}

variable "role_assignments" {
  default = {
    app_service_01_to_acr_01 = {
      scope           = "acr_01"
      role_owner      = "app_service_01"
      role_definition = "AcrPull"
    }
    app_service_02_to_acr_01 = {
      scope           = "acr_01"
      role_owner      = "app_service_02"
      role_definition = "AcrPull"
    }
    linux_virtual_machine_01_to_acr_01 = {
      scope           = "acr_01"
      role_owner      = "linux_virtual_machine_01"
      role_definition = "AcrPush"
    }
    linux_virtual_machine_01_to_app_service_01 = {
      scope           = "app_service_01"
      role_owner      = "linux_virtual_machine_01"
      role_definition = "Contributor"
    }
    linux_virtual_machine_01_to_app_service_02 = {
      scope           = "app_service_02"
      role_owner      = "linux_virtual_machine_01"
      role_definition = "Contributor"
    }
  }
}

variable "application_gateways" {
  default = {
    application_gateway_01 = {
      index                                       = 0
      name                                        = "coy-appgateway"
      resource_group_name                         = "resource_group_01"
      sku_name                                    = "Standard_v2"
      sku_tier                                    = "Standard_v2"
      sku_capacity                                = 2
      gateway_ip_configuration_name               = "my-gateway-ip-configuration"
      gateway_ip_configuration_subnet             = "vnet_app_subnet_appgateway"
      frontend_port_name                          = "feport"
      frontend_port_port                          = 80
      frontend_ip_configuration_name              = "frontend-ip"
      frontend_ip_configuration_public_ip_address = "public_ip_app_gateway"
      backend_http_settingses = {
        backend_http_setting_01 = {
          name                                = "apps-http-settings"
          cookie_based_affinity               = "Disabled"
          port                                = 80
          protocol                            = "Http"
          request_timeout                     = 60
          probe_name                          = "apps-probe"
          pick_host_name_from_backend_address = true
          path                                = "/"
        }
        backend_http_setting_02 = {
          name                                = "app1-http-settings"
          cookie_based_affinity               = "Disabled"
          port                                = 80
          protocol                            = "Http"
          request_timeout                     = 60
          probe_name                          = "app1-probe"
          pick_host_name_from_backend_address = true
          path                                = "/"
        }
        backend_http_setting_03 = {
          name                                = "app2-http-settings"
          cookie_based_affinity               = "Disabled"
          port                                = 80
          protocol                            = "Http"
          request_timeout                     = 60
          probe_name                          = "app2-probe"
          pick_host_name_from_backend_address = true
          path                                = "/"
        }
      }

      backend_address_pools = [
        {
          name      = "apps-backend-pool"
          resources = ["app_service_01", "app_service_02"]
        },
        {
          name      = "app1-backend-pool"
          resources = ["app_service_01"]
        },
        {
          name      = "app2-backend-pool"
          resources = ["app_service_02"]
        }
      ]

      probes = {
        probe_01 = {

          name                                      = "apps-probe"
          pick_host_name_from_backend_http_settings = true
          interval                                  = 30
          timeout                                   = 30
          unhealthy_threshold                       = 3
          protocol                                  = "Http"
          port                                      = 80
          path                                      = "/"
        }
        probe_02 = {
          name                                      = "app1-probe"
          pick_host_name_from_backend_http_settings = true
          interval                                  = 30
          timeout                                   = 30
          unhealthy_threshold                       = 3
          protocol                                  = "Http"
          port                                      = 80
          path                                      = "/"
        }
        probe_03 = {
          name                                      = "app2-probe"
          pick_host_name_from_backend_http_settings = true
          interval                                  = 30
          timeout                                   = 30
          unhealthy_threshold                       = 3
          protocol                                  = "Http"
          port                                      = 80
          path                                      = "/"
        }
      }
      http_listener_frontend_port_name                = "feport"
      http_listener_name                              = "listener"
      http_listener_frontend_ip_configuration_name    = "frontend-ip"
      http_listener_protocol                          = "Http"
      request_routing_rule_name                       = "rule"
      request_routing_rule_rule_type                  = "PathBasedRouting"
      request_routing_rule_http_listener_name         = "listener"
      request_routing_rule_backend_address_pool_name  = "apps-backend-pool"
      request_routing_rule_backend_http_settings_name = "apps-http-settings"
      request_routing_rule_url_path_map_name          = "path-map1"
      request_routing_rule_priority                   = "110"
      url_path_map_name                               = "path-map1"
      url_path_map_default_backend_http_settings_name = "apps-http-settings"
      url_path_map_default_backend_address_pool_name  = "apps-backend-pool"
      url_path_map_path_rules = {
        path_rule_01 = {
          name                       = "path1"
          paths                      = ["/web"]
          backend_address_pool_name  = "app1-backend-pool"
          backend_http_settings_name = "app1-http-settings"
        }
        path_rule_02 = {
          name                       = "path2"
          paths                      = ["/result"]
          backend_address_pool_name  = "app2-backend-pool"
          backend_http_settings_name = "app2-http-settings"
        }
      }
    }
  }
}
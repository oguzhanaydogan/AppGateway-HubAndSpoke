resource "azurerm_application_gateway" "appgw" {
  name                = var.name
  resource_group_name = var.resourcegroup
  location            = var.location
 
  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity
  }

  gateway_ip_configuration {
    name      = var.gateway_ip_configuration_name
    subnet_id = var.gateway_ip_configuration_subnet_id
  }

  frontend_port {
    name = var.frontend_port_name
    port = var.frontend_port_port
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = var.frontend_ip_configuration_public_ip_address_id
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
        name = backend_address_pool.key
        fqdns = backend_address_pool.value
    }
  }
  ###APPS
  dynamic "backend_http_settings" {
    for_each = var.backend_http_settingses
    content {
        name                  = backend_http_settings.value.name
        cookie_based_affinity = backend_http_settings.value.cookie_based_affinity
        port                  = backend_http_settings.value.port
        protocol              = backend_http_settings.value.protocol
        request_timeout       = backend_http_settings.value.request_timeout
        probe_name            = backend_http_settings.value.probe_name
        pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
        path = backend_http_settings.value.path
    }
  }
  dynamic "probe" {
    for_each = var.probes
    content {
    name                = probe.value.name
    pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
    interval            = probe.value.interval
    timeout             = probe.value.timeout
    unhealthy_threshold = probe.value.unhealthy_threshold
    protocol            = probe.value.protocol
    port                = probe.value.port
    path                = probe.value.path
    }
  }

  http_listener {
    name                           = var.http_listener_name
    frontend_ip_configuration_name = var.http_listener_frontend_ip_configuration_name
    frontend_port_name             = var.http_listener_frontend_port_name
    protocol                       = var.http_listener_protocol
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = var.request_routing_rule_rule_type
    http_listener_name         = var.request_routing_rule_http_listener_name
    backend_address_pool_name  = var.request_routing_rule_backend_address_pool_name
    backend_http_settings_name = var.request_routing_rule_backend_http_settings_name   
    url_path_map_name = var.request_routing_rule_url_path_map_name
    priority = var.request_routing_rule_priority
  }

  url_path_map{
    name = var.url_path_map_name
    default_backend_http_settings_name = var.url_path_map_default_backend_http_settings_name
    default_backend_address_pool_name  = var.url_path_map_default_backend_address_pool_name

    dynamic "path_rule" {
        for_each = var.url_path_map_path_rules
        content {
            name = path_rule.value.name
            paths = path_rule.value.paths
            backend_address_pool_name = path_rule.value.backend_address_pool_name
            backend_http_settings_name = path_rule.value.backend_http_settings_name
      }
    }
  }
}
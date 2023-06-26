output "instrumentation_key" {
    value = azurerm_application_insights.insight.instrumentation_key
}

output "connection_string" {
    value = azurerm_application_insights.insight.connection_string
}
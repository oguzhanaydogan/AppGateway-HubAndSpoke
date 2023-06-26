output "principal_id" {
    value = azurerm_virtual_machine.vm1.identity[0].principal_id
  
}
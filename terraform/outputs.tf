output "resource_group_name" {
  value = azurerm_resource_group.rg-flask-app.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.flask-app-vm.public_ip_address
}

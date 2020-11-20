# Outputs: Virtual Machine Info
output "res_out_vm_name" {
  value = azurerm_virtual_machine.virtual_machine.name
}

output "res_out_vm_id" {
  value = azurerm_virtual_machine.virtual_machine.id
}

output "res_out_os_disk" {
  value = azurerm_virtual_machine.virtual_machine.storage_os_disk[0].managed_disk_id
}

output "res_out_nic_name" {
  value = azurerm_network_interface.nics.*.name
}

output "res_out_nic_id" {
  value = azurerm_network_interface.nics.*.id
}

output "res_out_nic_ip" {
  value = azurerm_network_interface.nics.*.private_ip_address
}

output "res_out_data_disk" {
  value = azurerm_managed_disk.data_disk.*.id
}
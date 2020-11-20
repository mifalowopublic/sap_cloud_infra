resource "azurerm_network_interface" "nics" {
  count                                                         = length(var.req_arth_nic_config)
  name                                                          = "${var.req_arth_nic_config[count.index].nic_name}-eth0"
  location                                                      = var.req_arth_vm_config.location
  resource_group_name                                           = var.req_arth_vm_config.resource_group_name
  enable_accelerated_networking                                 = true
  tags                                                          = var.req_arth_vm_config.tag

  ip_configuration {
    name                                                        = "ipconfig"
    subnet_id                                                   = var.req_arth_sen_data_config.subnet_id
    primary                                                     = true
    private_ip_address                                          = var.req_arth_nic_config[count.index].private_ip_address
    private_ip_address_allocation                               = "Static"
  }
}

resource "azurerm_virtual_machine" "virtual_machine" {
  name                                                          = var.req_arth_vm_config.name
  location                                                      = var.req_arth_vm_config.location
  resource_group_name                                           = var.req_arth_vm_config.resource_group_name
  network_interface_ids                                         = [for nic in azurerm_network_interface.nics: nic.id]
  primary_network_interface_id                                  = element(azurerm_network_interface.nics.*.id, 0)
  vm_size                                                       = var.req_arth_vm_config.vm_size
  license_type                                                  = var.req_arth_vm_config.license_type
  availability_set_id                                           = var.req_arth_vm_config.availability_set_id != "" ? var.req_arth_vm_config.availability_set_id : null
  storage_image_reference {
    id = var.req_arth_vm_config.source_image_id
  }

  storage_os_disk {
    name                                                        = "${var.req_arth_vm_config.name}-OS"
    caching                                                     = var.req_arth_vm_config.caching
    create_option                                               = var.req_arth_vm_config.create_option
    disk_size_gb                                                = var.req_arth_vm_config.disk_size_gb
    managed_disk_type                                           = var.req_arth_vm_config.managed_disk_type
  }

  os_profile {
    computer_name                                               = var.req_arth_vm_config.name
    admin_username                                              = var.req_arth_sen_data_config.admin_username
    admin_password                                              = var.req_arth_sen_data_config.admin_password
  }
  
  os_profile_windows_config {
    provision_vm_agent = true
  }

  boot_diagnostics {
    enabled                                                     = var.req_arth_vm_config.boot_diagnostics_enabled
    storage_uri                                                 = var.req_arth_sen_data_config.storage_uri
  }

  tags                                                          = var.req_arth_vm_config.tag
}

resource "azurerm_managed_disk" "data_disk" {
  count                                                         = length(var.req_arth_data_disk)
  name                                                          = "${var.req_arth_vm_config.name}-${var.req_arth_data_disk[count.index].name}"
  location                                                      = var.req_arth_vm_config.location
  resource_group_name                                           = var.req_arth_vm_config.resource_group_name
  storage_account_type                                          = var.req_arth_data_disk[count.index].managed_disk_type
  create_option                                                 = var.req_arth_data_disk[count.index].create_option
  disk_size_gb                                                  = var.req_arth_data_disk[count.index].disk_size_gb
  tags                                                          = var.req_arth_vm_config.tag
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attach" {
  count                                                         = length(azurerm_managed_disk.data_disk)
  managed_disk_id                                               = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id                                            = azurerm_virtual_machine.virtual_machine.id
  lun                                                           = count.index
  caching                                                       = var.req_arth_data_disk[count.index].caching
  write_accelerator_enabled                                     = var.req_arth_data_disk[count.index].write_accelerator_enabled
}

resource "azurerm_template_deployment" "terraform-extension" {
  name                                                          = "${azurerm_virtual_machine.virtual_machine.name}-extension"
  resource_group_name                                           = azurerm_virtual_machine.virtual_machine.resource_group_name

  template_body                                                 = file("extension.json")

  parameters = {
    "vmName" = var.req_arth_vm_config.name
  }

  deployment_mode = "Incremental"
}

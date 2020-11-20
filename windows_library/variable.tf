variable "req_arth_sen_data_config" {
  description = "Sensitive data source information"
  type = object({
    subnet_id                                                   = string
    admin_username                                              = string
    admin_password                                              = string
    storage_uri                                                 = string
  })
}

variable "req_arth_nic_config" {
  description = "Network interface information"
  type = list(object({
    nic_name                                                    = string
    private_ip_address                                          = string
    enable_accelerated_networking                               = bool
    config_name                                                 = string
    private_ip_address_allocation                               = string
  }))
}

variable "req_arth_vm_config" {
  description = "Virtual machine config information"
  type = object({
    name                                                        = string
    location                                                    = string
    resource_group_name                                         = string
    vm_size                                                     = string
    availability_set_id                                         = string
    tag                                                         = map(string)
    source_image_id                                             = string
    license_type                                                = string
    caching                                                     = string
    create_option                                               = string
    disk_size_gb                                                = number
    managed_disk_type                                           = string
    provision_vm_agent                             = bool
    boot_diagnostics_enabled                                    = bool
  })
}

variable "req_arth_data_disk" {
  description = "Data Disk Information"
  type = list(object({
    name                                                        = string
    caching                                                     = string
    create_option                                               = string
    disk_size_gb                                                = number
    managed_disk_type                                           = string
    write_accelerator_enabled                                   = bool
  }))
}

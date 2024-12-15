variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region for the resource deployment"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet within the virtual network"
  type        = string
}

variable "public_ip_name" {
  description = "The name of the public IP resource"
  type        = string
}

variable "nsg_name" {
  description = "The name of the network security group"
  type        = string
}

variable "network_interface_name" {
  description = "The name of the network interface"
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
}

variable "os_disk_name" {
  description = "The name of the operating system disk for the VM"
  type        = string
}

variable "username" {
  description = "The admin username for the virtual machine and SSH"
  type        = string
}

variable "publisher" {
  description = "The publisher of the image"
  type        = string
}

variable "offer" {
  description = "The offer of the image"
  type        = string
}

variable "sku" {
  description = "The SKU of the image"
  type        = string
}

variable "image_version" {
  description = "The version of the image"
  type        = string
}

variable "ansible_inventory_filename" {
  description = "The filename for the generated Ansible inventory file"
  type        = string
}

variable "public_key_path" {
  description = "The path to the public SSH key"
  type        = string
}

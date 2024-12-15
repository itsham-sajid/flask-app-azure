resource "azurerm_resource_group" "rg-flask-app" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "flask-app-network" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-flask-app.location
  resource_group_name = azurerm_resource_group.rg-flask-app.name
}

resource "azurerm_subnet" "flask-app-subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg-flask-app.name
  virtual_network_name = azurerm_virtual_network.flask-app-network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "flask-app-public_ip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.rg-flask-app.location
  resource_group_name = azurerm_resource_group.rg-flask-app.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "flask-app-nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg-flask-app.location
  resource_group_name = azurerm_resource_group.rg-flask-app.name

  security_rule {
    name                       = "SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "flask-app-nic" {
  name                = var.network_interface_name
  location            = azurerm_resource_group.rg-flask-app.location
  resource_group_name = azurerm_resource_group.rg-flask-app.name

  ip_configuration {
    name                          = "flask-app-nic-configuration"
    subnet_id                     = azurerm_subnet.flask-app-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.flask-app-public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "flask-app-nsg-assoc" {
  network_interface_id      = azurerm_network_interface.flask-app-nic.id
  network_security_group_id = azurerm_network_security_group.flask-app-nsg.id
}

resource "azurerm_linux_virtual_machine" "flask-app-vm" {
  name                  = var.vm_name
  location              = azurerm_resource_group.rg-flask-app.location
  resource_group_name   = azurerm_resource_group.rg-flask-app.name
  network_interface_ids = [azurerm_network_interface.flask-app-nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = var.os_disk_name
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.image_version
  }

  computer_name                   = var.vm_name
  admin_username                  = var.username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.username
    public_key = file(var.public_key_path)
  }
}

resource "local_file" "ansible_inventory" {
  sensitive_content = <<EOT
[flask_servers]
flask_server_prod ansible_host=${azurerm_public_ip.flask-app-public_ip.ip_address} ansible_user=${var.username} ansible_ssh_private_key_file=~/.ssh/id_rsa
EOT

  filename = var.ansible_inventory_filename
}

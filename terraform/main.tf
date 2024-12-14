resource "azurerm_resource_group" "rg-flask-app" {
  name     = "rg-flask-app"
  location = "UK South"
}
resource "azurerm_virtual_network" "flask-app-network" {
  name                = "flask-app-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-flask-app.location
  resource_group_name = azurerm_resource_group.rg-flask-app.name
}

resource "azurerm_subnet" "flask-app-subnet" {
  name                 = "flask-app-subnet"
  resource_group_name  = azurerm_resource_group.rg-flask-app.name
  virtual_network_name = azurerm_virtual_network.flask-app-network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "flask-app-public_ip" {
  name                = "flask-app-PublicIP"
  location            = azurerm_resource_group.rg-flask-app.location
  resource_group_name = azurerm_resource_group.rg-flask-app.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "flask-app-nsg" {
  name                = "flask-app-NetworkSecurityGroup"
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
  name                = "flask-app-myNIC"
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
  name                  = "flask-app-vm"
  location              = azurerm_resource_group.rg-flask-app.location
  resource_group_name   = azurerm_resource_group.rg-flask-app.name
  network_interface_ids = [azurerm_network_interface.flask-app-nic.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "flask-app-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name                   = "flask-app-vm"
  admin_username                  = "flaskappuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "flaskappuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

resource "local_file" "ansible_inventory" {
  content = <<EOT
[flask_servers]
${azurerm_public_ip.flask-app-public_ip.ip_address} ansible_user=flaskappuser ansible_ssh_private_key_file=~/.ssh/id_rsa
EOT

  filename = "../ansible/inventory.ini"
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }


  backend "azurerm" {
    resource_group_name  = "rg-flask-app"
    storage_account_name = "flaskterraform"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}
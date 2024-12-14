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

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

}

provider "azurerm" {
  features {}
}

variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
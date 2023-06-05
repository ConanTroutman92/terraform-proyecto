# plugins proveedores
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.4.0"
    }
    github = {
      source = "integrations/github"
    }
  }
}

# configuracion proveedor azure
provider "azurerm" {
  features {}
  # es mas facil logearse con la azure cloud shell que usar todas estas cosas de abajo
  subscription_id = var.subscription_id
  client_id       = var.client_id
  tenant_id       = var.tenant_id
  client_secret   = var.client_secret
}

# configuracion proveedor random (para generar valores aleatorios) (no necesita)
provider "random" {

}

# configuracion proveedor github (autenticacion con token)
provider "github" {
  # token cuenta github (se crea en las opciones de desarrollador)
  token = var.github_token
}



# token de la web app creada en azure (se usa para crear el secreto en github)
locals {
  api_token_var = "AZURE_STATIC_WEB_APPS_API_TOKEN"
}

# recurso secreto github
resource "github_actions_secret" "secret" {
  repository      = "web3"
  secret_name     = local.api_token_var
  plaintext_value = azurerm_static_site.webapp.api_key
}



# recursos de random (nombres de mascotas y numeros)
resource "random_pet" "rg-pet" {
  length    = 3
  separator = "."
}

resource "random_pet" "web-pet" {
  length    = 2
  separator = "-"
}

resource "random_integer" "rg-int" {
  min = 1
  max = 9
}

resource "random_integer" "web-int" {
  min = 101
  max = 237
}




# grupo de recursos
resource "azurerm_resource_group" "grupo" {
  name     = "grupo-${random_pet.rg-pet.id}-${random_integer.rg-int.result}"
  location = var.location
}

# web estatica
resource "azurerm_static_site" "webapp" {
  name                = "webapp-${random_pet.web-pet.id}-${random_integer.web-int.result}"
  location            = azurerm_resource_group.grupo.location
  resource_group_name = azurerm_resource_group.grupo.name
  sku_size            = var.sku_size
}

# subida workflow github
resource "github_repository_file" "workflow" {
  depends_on = [ azurerm_static_site.webapp ]
  repository = "web3"
  branch     = "main"
  file       = ".github/workflows/azure-static-web-app.yml"
  content = file("./azure-static-web-app.yml")
 
  commit_message      = "añadir workflow con terraform"
  commit_author       = "Terraform"
  commit_email        = "terraform@terraform.tf"

  overwrite_on_create = true
}



# outputs
output "subscription_id_oculto" {
  value = var.subscription_id
  sensitive = true
}
output "github_token_visible" {
  value = var.github_token
}

output "token-web" {
  value = azurerm_static_site.webapp.api_key
}

output "url-original" {
  value = "https://${azurerm_static_site.webapp.default_host_name}"
}

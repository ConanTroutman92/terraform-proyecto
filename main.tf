terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Define el proveedor de Azure
provider "azurerm" {
  features {}
  #subscription_id = ""
  #client_id       = ""
  #client_secret   = var.azure_password
  #tenant_id       = ""
}

# Crea un grupo de recursos
resource "azurerm_resource_group" "rg" {
  name     = "crud-empleados-3465645"
  location = "West Europe"
}

# Crea una instancia de base de datos MySQL
resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "la-base-de-datos-de-empleados-3465645"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  administrator_login          = "Admin_1234"
  administrator_password = "Stark_4321"

  sku_name     = "B_Standard_B1s"
  #storage_mb   = 5120
  #version      = "5.7"
  
 

  

}

# Crea una base de datos MySQL dentro de la instancia de MySQL
resource "azurerm_mysql_flexible_database" "mysqldb" {
  name                = "mydatabase"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}


# Crea una aplicación web de PHP
resource "azurerm_service_plan" "appserviceplan" {
  name                = "my-appservice-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
 
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "appservice" {
  name                = "la-web-de-prueba-de-empleados-3465645"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id = azurerm_service_plan.appserviceplan.id
  https_only          = true
 

  site_config {
    always_on = true
    #php_version = "8.2"
    #linux_fx_version = "PHP|7.4"
    application_stack{
    php_version = "8.2"
 }
  }

  connection_string {
    name = "MySqlConnectionString"
    type = "MySql"
    value = "Server=tcp:${azurerm_mysql_flexible_server.mysql.fqdn},3306;Database=${azurerm_mysql_flexible_database.mysqldb.name};User Id=${azurerm_mysql_flexible_server.mysql.administrator_login}@${azurerm_mysql_flexible_server.mysql.name};Password=${azurerm_mysql_flexible_server.mysql.administrator_password};"
  }

#  app_settings = {
#    "WEBSITE_TIME_ZONE" = "Pacific Standard Time"
#  }

#  identity {
#    type = "SystemAssigned"
#  }

}




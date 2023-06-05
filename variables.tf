# variables

variable "location" {
  description = "region donde se crean los recursos"
  default     = "West Europe"
}

variable "sku_size" {
  description = "plan de hospedaje (ancho de banda, almacenamiento...)"
  default     = "Standard"
}




variable "subscription_id" {
  description = "id de suscripcion de azure"
  sensitive   = true
}

variable "client_id" {
  description = "id de aplicacion (cliente)"
  sensitive   = true
}

variable "tenant_id" {
  description = "id de directorio (inquilino)"
  sensitive   = true
}
variable "client_secret" {
  description = "secreto del cliente (valor)"
  sensitive   = true
}




variable "github_token" {
  description = "token de tu cuenta de github"
}



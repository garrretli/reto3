provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  features {}
}
resource "azurerm_resource_group" "tarea1" {
  name     = "RG01"
  location = local.region
  
}

resource "azurerm_app_service_plan" "app_serv_plan_01" {
  name                = "app_serv_plan_01"
  location            = azurerm_resource_group.tarea1.location
  resource_group_name = azurerm_resource_group.tarea1.name

  sku {
    tier = "Free"
    size = "F"
  }
}

resource "azurerm_app_service" "app_serv_01" {
  name                = "app_serv_01"
  location            = azurerm_resource_group.tarea1.location
  resource_group_name = azurerm_resource_group.tarea1.name
  app_service_plan_id = azurerm_app_service_plan.app_serv_plan_01.id

}
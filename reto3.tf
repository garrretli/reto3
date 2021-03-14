provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  features {}
}
resource "azurerm_resource_group_banco" "rg_banco" {
  name     = "RG01"
  location = local.region 
}

resource "azurerm_resource_group_Apps" "rg_Apps" {
  name     = "RG01"
  location = local.region 
}
resource "azurerm_virtual_network" "VnetApps" {
  name                = "VnetApps"
  location            = azurerm_resource_group.rg_Apps.location
  resource_group_name = azurerm_resource_group.rg_Apps.name
  address_space       = ["192.168.0.0/26"]
  dns_servers         = ["x.x.x.x", "x.x.x.x"]

  }

  subnet {
    name           = "subnet1"
    address_prefix = "192.168.0.0/26"
  }

resource "azurerm_cdn_profile" "cdn_apps_profile" {
  name                = "apps-cdn"
  location            = azurerm_resource_group.rg_Apps.location
  resource_group_name = azurerm_resource_group.rg_Apps.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "cdn_apps_endpoint" {
  name                = "cdnAppEndpoint"
  profile_name        = azurerm_cdn_profile.cdn_apps_profile.name
  location            = azurerm_resource_group.rg_Apps.location
  resource_group_name = azurerm_resource_group.rg_Apps.name

  origin {
    name      = "banco_origin"
    host_name = "www.bancomentoring.com"
  }
}

resource "azurerm_storage_account" "cdn_storage" {
  name                     = "cdn_storageaccountname"
  resource_group_name      = azurerm_resource_group.rg_Apps.name
  location                 = azurerm_resource_group.rg_Apps.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  }
}


resource "azurerm_resource_group_homebanking" "rg_homebanking" {
  name     = "RG01"
  location = local.region 
}

resource "azurerm_virtual_network" "Vnethomebanking" {
  name                = "Vnethomebaking"
  location            = azurerm_resource_group.rg_homebanking.location
  resource_group_name = azurerm_resource_group.rg_homebanking.name
  address_space       = ["192.168.0.64/26"]
  dns_servers         = ["x.x.x.x", "x.x.x.x"]

  }

  subnet {
    name           = "subnet1"
    address_prefix = "192.168.0.64/26"
  }


resource "azurerm_resource_group_connectivity" "rg_connectivity" {
  name     = "RG01"
  location = local.region 
}
resource "azurerm_virtual_network" "Vnetconnectivity" {
  name                = "Vnetconnectivity"
  location            = azurerm_resource_group.rg_connectivity.location
  resource_group_name = azurerm_resource_group.rg_connectivity.name
  address_space       = ["192.168.0.128/25"]
  dns_servers         = ["x.x.x.x", "x.x.x.x"]

  }

  subnet {
    name           = "subnet1"
    address_prefix = "192.168.0.128/26"
  }
  subnet {
    name           = "subnet2"
    address_prefix = "192.168.0.192/26"
  }


resource "azurerm_frontdoor" "fd_banco" {
  name                                         = "banco-FrontDoor"
  location                                     = local.region
  resource_group_name                          = azurerm_resource_group.rg_banco.name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "banco-RoutingRule1"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["contosobanco1"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "banco-Backend"
    }
  }

  backend_pool_load_balancing {
    name = "bancoLoadBalancingSettings1"
  }

  backend_pool_health_probe {
    name = "bancoHealthProbeSetting1"
  }

  backend_pool {
    name = "banco-Backend"
    backend {
      host_header = "www.contosobanco.com"
      address     = "www.contosobanco.com"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "bancoLoadBalancingSettings1"
    health_probe_name   = "bancoHealthProbeSetting1"
  }

  frontend_endpoint {
    name                              = "contosobanco1"
    host_name                         = "bancoFrontDoor.azurefd.net"
    custom_https_provisioning_enabled = false
  }

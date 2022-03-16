resource "azurerm_resource_group" "cluster" {
  name     = "rg-tf-demo"
  location = "westeurope"
}

resource "azurerm_virtual_network" "cluster" {
  name                = "vnet-tf-demo"
  location            = azurerm_resource_group.cluster.location
  resource_group_name = azurerm_resource_group.cluster.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "cluster" {
  name                 = "aks"
  resource_group_name  = azurerm_resource_group.cluster.name
  virtual_network_name = azurerm_virtual_network.cluster.name
  address_prefixes     = ["10.0.0.0/24"]
}

module "aks" {
  source  = "crayon/aks/azurerm"
  version = "1.7.0"

  name                      = "aks-tf-demo"
  resource_group            = azurerm_resource_group.cluster.name
  admin_groups              = data.azuread_groups.admins.object_ids
  kubernetes_version_prefix = "1.22"

  network_plugin = "azure"
  subnet_id      = azurerm_subnet.cluster.id

  default_node_pool = {
    name = "default"

    vm_size             = "Standard_D4s_v4"
    node_count          = 2
    enable_auto_scaling = false
    min_count           = null
    max_count           = null
    node_labels = {
      "type" = "generic"
    }
    additional_settings = {
      max_pods        = 50
      os_disk_size_gb = 60
    }
  }

  depends_on = [azurerm_resource_group.cluster]
}

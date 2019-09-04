variable "deploy-name" {}
variable "location" {
    default  = "west europe"
}
resource "azurerm_resource_group" "terraform" {
    name     = "rg-${var.deploy-name}"
    location = "${var.location}"
}
module "aci" {
    source                = "Azure/aci/azurerm"
    dns_name_label        = "${var.deploy-name}-container"
    os_type               = "linux"
    image_name            = "nginx"
    resource_group_name   = "${azurerm_resource_group.terraform.name}" # Fetch name given to Resource Group
    container_group_name  = "web-${var.deploy-name}"
    container_name        = "container-${var.deploy-name}"
    location              = "${var.location}"
    cpu_core_number       = "1"
    memory_size           = "1"
    port_number           = "80"
}
# Azure Traffic Manager, profile
resource "azurerm_traffic_manager_profile" "terraform" {
    name                    = "trmg-${var.deploy-name}"
    resource_group_name     = "${azurerm_resource_group.terraform.name}"
    traffic_routing_method  = "Priority"
    dns_config {
        relative_name       = "${var.deploy-name}-dns"
        ttl                 = 100
    }
    monitor_config {
        protocol            = "http"
        port                = 80
        path                = "/"
    }
}
# Azure Traffic Manager, endpoint in Azure
resource "azurerm_traffic_manager_endpoint" "terraform" {
    name                = "${var.deploy-name}-endpoint"
    resource_group_name = "${azurerm_resource_group.terraform.name}"
    profile_name        = "${azurerm_traffic_manager_profile.terraform.name}"
    target              = "${module.aci.containergroup_fqdn}"
    type                = "externalEndpoints"
    weight              = 100
}
resource "azurerm_dns_cname_record" "terraform" {
    name                = "demo"
    zone_name           = "terraform.skyarkitektur.no"
    resource_group_name = "demo"
    ttl                 = 300
    record              = "${azurerm_traffic_manager_profile.terraform.fqdn}"
}
output "fqdn" {
    value = "${module.aci.containergroup_fqdn}"
}
output "id" {
    value = "${module.aci.containergroup_id}"
}
output "endpoint-traffic_manager" {
    value = "${azurerm_traffic_manager_profile.terraform.fqdn}"
}
output "dns-cname" {
    value = "${azurerm_dns_cname_record.terraform.name}.${azurerm_dns_cname_record.terraform.record}"
}
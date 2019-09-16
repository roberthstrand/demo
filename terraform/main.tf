variable "deployname" {
    default = "tftest"
}
variable "location" {
    default  = "west europe"
}
resource "azurerm_resource_group" "terraform" {
    name     = "rg-${var.deployname}"
    location = "${var.location}"
}
module "aci" {
    source                = "Azure/aci/azurerm"
    dns_name_label        = "${var.deployname}-container"
    os_type               = "linux"
    image_name            = "nginx"
    resource_group_name   = "${azurerm_resource_group.terraform.name}" # Fetch name given to Resource Group
    container_group_name  = "web-${var.deployname}"
    container_name        = "container-${var.deployname}"
    location              = "${var.location}"
    cpu_core_number       = "1"
    memory_size           = "1"
    port_number           = "80"
}
resource "azurerm_dns_cname_record" "terraform" {
    name                = "demo"
    zone_name           = "terraform.skyarkitektur.no"
    resource_group_name = "demo"
    ttl                 = 300
    record              = "${module.aci.containergroup_fqdn}"
}
output "fqdn" {
    value = "${module.aci.containergroup_fqdn}"
}
output "id" {
    value = "${module.aci.containergroup_id}"
}
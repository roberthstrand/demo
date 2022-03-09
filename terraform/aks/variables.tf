data "azuread_groups" "admins" {
  display_names = ["aks-admin"]
}

variable "clients" {
  type = string
}

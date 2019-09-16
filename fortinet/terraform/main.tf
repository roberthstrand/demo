resource "fortios_firewall_object_vip" "test" {
    name = "dfa"
    comment = "Terraform.io"
    extip = "11.1.1.1-21.1.1.1"
    mappedip = ["22.2.2.2-32.2.2.2"]
    extintf = "port2"
    portforward = "enable"
    protocol = "tcp"
    extport = "2-3"
    mappedport = "4-5"
}
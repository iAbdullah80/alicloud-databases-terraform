// THis is the security group for the http server, it allows traffic on port 80 and 22 from any source

resource "alicloud_security_group" "http" {
  name        = "http"
  vpc_id = alicloud_vpc.capstone_vpc.id
}

resource "alicloud_security_group_rule" "ssh_for_http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.http.id
  source_security_group_id = alicloud_security_group.bastion.id
}
resource "alicloud_security_group_rule" "http_for_http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = alicloud_security_group.http.id
  cidr_ip           = "0.0.0.0/0"
}


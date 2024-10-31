// This is the security group for the bastion server, it allows traffic on port 80 and 22 from any source

resource "alicloud_security_group" "bastion" {
  name        = "bastion"
  vpc_id = alicloud_vpc.capstone_vpc.id
}

resource "alicloud_security_group_rule" "ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.bastion.id
  cidr_ip           = "0.0.0.0/0"
}

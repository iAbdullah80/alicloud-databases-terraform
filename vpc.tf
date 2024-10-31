// 1- VPC
resource "alicloud_vpc" "capstone_vpc" {
  vpc_name   = "vpc-lab" // Name of the VPC
  cidr_block = "10.0.0.0/8" // CIDR block of the VPC
}

// 2- VSwitch

// get the available zones
data "alicloud_zones" "default" {}
// Create a public vswitch
resource "alicloud_vswitch" "vswitch" {
  vswitch_name      = "public" // Name of the VSwitch
  cidr_block        = "10.0.1.0/24" // CIDR block of the VSwitch
  vpc_id            = "${alicloud_vpc.capstone_vpc.id}" // ID of the VPC to which the VSwitch belongs
  zone_id = "${data.alicloud_zones.default.zones.0.id}" // ID of the zone in which the VSwitch is created, its A
}

// Create a another public vswitch
resource "alicloud_vswitch" "vswitch_b" {
  vswitch_name      = "public_b"
  cidr_block        = "10.0.3.0/24"
  vpc_id            = "${alicloud_vpc.capstone_vpc.id}"
  zone_id = "${data.alicloud_zones.default.zones.1.id}" // ID of the zone in which the VSwitch is created, its B
}

// Create a private vswitch
resource "alicloud_vswitch" "vswitch_private" {
  vswitch_name      = "private"
  cidr_block        = "10.0.2.0/24"
  vpc_id            = "${alicloud_vpc.capstone_vpc.id}"
  zone_id = "${data.alicloud_zones.default.zones.0.id}" // ID of the zone in which the VSwitch is created, its A
}

// 3- NAT

resource "alicloud_nat_gateway" "NAT_gateway" {
  vpc_id           = alicloud_vpc.capstone_vpc.id // ID of the VPC to which the NAT Gateway belongs
  nat_gateway_name = "NAT" // Name of the NAT Gateway
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.vswitch.id // ID of the VSwitch to which the NAT Gateway belongs
  nat_type         = "Enhanced"
}
// Elastic IP, this is the IP that will be used to access the internet
resource "alicloud_eip_address" "nat_eip" {
  description               = "EIP for NAT"
  address_name              = "NAT-EIP"
  netmode                   = "public" // The network type of the EIP, it can be public or private
  payment_type              = "PayAsYouGo"
  internet_charge_type      = "PayByTraffic"

}
// Associate the EIP with the NAT Gateway
resource "alicloud_eip_association" "example" {
  allocation_id = alicloud_eip_address.nat_eip.id // ID of the EIP to associate
  instance_id   = alicloud_nat_gateway.NAT_gateway.id // ID of the NAT Gateway to which the EIP is associated
  instance_type = "Nat" // The type of the instance to associate with the EIP, it can be Nat or Slb
}
// SNAT entry, this is used to configure the SNAT rule for the NAT Gateway
resource "alicloud_snat_entry" "default" {
  snat_table_id     = alicloud_nat_gateway.NAT_gateway.snat_table_ids // ID of the SNAT table from the NAT Gateway
  source_vswitch_id = alicloud_vswitch.vswitch_private.id // ID of the source VSwitch
  snat_ip           = alicloud_eip_address.nat_eip.ip_address // The public IP address used for SNAT
}
// Route table
resource "alicloud_route_table" "table" {
  description      = "test-description"
  vpc_id           = alicloud_vpc.capstone_vpc.id // ID of the VPC to which the route table belongs
  route_table_name = "nat-route-table"
  associate_type   = "VSwitch" // The type of the associated resource, it can be VSwitch or VPC
  
}
// Route entry, this is used to configure the route entry for the route table
resource "alicloud_route_entry" "entry" {
  route_table_id        = alicloud_route_table.table.id // ID of the route table
  destination_cidrblock = "0.0.0.0/0" // The destination CIDR block of the route entry
  nexthop_type          = "NatGateway" // The type of the next hop, which is the NAT Gateway
  nexthop_id            = alicloud_nat_gateway.NAT_gateway.id // ID of the next hop, which is the NAT Gateway
}
// Route table attachment, this is used to attach the route table to the VSwitch
resource "alicloud_route_table_attachment" "attach" {
  vswitch_id     = alicloud_vswitch.vswitch_private.id // ID of the VSwitch to which the route table is attached to
  route_table_id = alicloud_route_table.table.id // ID of the route table to attach to the VSwitch
}

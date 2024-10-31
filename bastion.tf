// This is a jump box servver that will be used to connect to the other servers in the private subnet,
// this jump box is now on zone A, and uses secure group bastion, and the key pair myKeytest, also its on the public subnet vswitch
// internet_max_bandwidth_out is 100 so it will have a public ip, 

resource "alicloud_instance" "bastion" {
  availability_zone = data.alicloud_zones.default.zones.0.id
  security_groups   = [alicloud_security_group.bastion.id]

  instance_type              = "ecs.g6.large"
  system_disk_category       = "cloud_essd"
  system_disk_size           = 20
  image_id                   = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  instance_name              = "jump-box"
  vswitch_id                 = alicloud_vswitch.vswitch.id
  internet_max_bandwidth_out = 100
  internet_charge_type       = "PayByTraffic"
  instance_charge_type       = "PostPaid"
  key_name                   = alicloud_ecs_key_pair.myKey.key_pair_name
}

output "ip" {
  value = alicloud_instance.bastion.public_ip
}
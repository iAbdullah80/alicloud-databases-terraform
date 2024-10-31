// This is our web server that will be used to serve the web page, it is on zone A, 
// and uses secure group http, and the key pair myKeytest, also its on the private subnet vswitch
// internet_max_bandwidth_out is 0 so it will not have a public ip, also it uses the user data to
// install docker and clone the repo to run the web server, also the template file is used to pass the redis host ip
// and the name of the server, The count is set to 2 so we can create 2 instances
// THIS SERVER IS ON THE PRIVATE SUBNET

resource "alicloud_instance" "web-instance-test" {
  availability_zone = data.alicloud_zones.default.zones.0.id
  security_groups   = [alicloud_security_group.http.id]
  count = 2

  instance_type              = "ecs.g6.large"
  system_disk_category       = "cloud_essd"
  system_disk_size           = 40
  image_id                   = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  instance_name              = "web-server${count.index}"
  vswitch_id                 = alicloud_vswitch.vswitch_private.id
  internet_max_bandwidth_out = 0
  instance_charge_type       = "PostPaid"
  key_name                   = alicloud_ecs_key_pair.myKey.key_pair_name
  user_data = base64encode(templatefile("http.tpl", {
    redis_host = alicloud_kvstore_instance.redis.private_ip, 
    db_host= alicloud_db_instance.mysql.private_ip_address,
    db_password= var.database_password
    }))
}

output "http-ip" {
  value = alicloud_instance.web-instance-test.*.private_ip
  
}

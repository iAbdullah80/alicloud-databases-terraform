// MySQL
resource "alicloud_db_instance" "mysql" {
    instance_name = "mysql"
    engine = "MySQL"
    engine_version = "8.0"
    instance_type = "mysql.n2.medium.1"
    instance_storage = 20
    vpc_id = alicloud_vpc.capstone_vpc.id
    vswitch_id = alicloud_vswitch.vswitch_private.id
    zone_id = data.alicloud_zones.default.zones.0.id
    instance_charge_type = "Postpaid"
    category = "Basic"
    security_ips = ["0.0.0.0/0"]
}

resource "alicloud_rds_account" "user" {
    db_instance_id = alicloud_db_instance.mysql.id
    account_name = "user"
    account_password = var.database_password
    account_type = "Super"
}

resource "alicloud_db_database" "mysql" {
    instance_id = alicloud_db_instance.mysql.id
    name = "mydatabase"
}



// Redis
resource "alicloud_kvstore_instance" "redis" {
  db_instance_name = "redis"
  vswitch_id = alicloud_vswitch.vswitch_private.id
  security_group_id = alicloud_security_group.redis-sg.id
  zone_id = data.alicloud_zones.default.zones.0.id
  instance_class = "redis.logic.sharding.2g.2db.0rodb.4proxy.default"
  instance_type = "Redis"
  engine_version = "5.0"
  vpc_auth_mode = "Close" # Close means that Redis can be accessed without authentication
  security_ips = ["0.0.0.0/0"]
}


// Outputs

// MySQL
output "mysql-ip" {
    value = alicloud_db_instance.mysql.private_ip_address
}


// Redis
output "redis-ip" {
    value = alicloud_kvstore_instance.redis.private_ip
  
}
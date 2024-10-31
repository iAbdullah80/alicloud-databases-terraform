// Mysql does mot need security group


// Redis requires a security group initialization only no need for rules
resource "alicloud_security_group" "redis-sg" {
  name = "redis-sg"
  vpc_id = alicloud_vpc.capstone_vpc.id
}

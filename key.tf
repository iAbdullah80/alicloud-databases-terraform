// Create a key pair

resource "alicloud_ecs_key_pair" "myKey" {
  key_pair_name = "my-key"
  resource_group_id = alicloud_vpc.capstone_vpc.resource_group_id
  key_file = "my-ecs-key.pem"
}

resource "alicloud_nlb_load_balancer" "default" {
  load_balancer_name = "http-load-balancer"
  load_balancer_type = "Network"
  address_type       = "Internet"
  address_ip_version = "Ipv4"
  vpc_id             = alicloud_vpc.capstone_vpc.id
  zone_mappings {
    vswitch_id = alicloud_vswitch.vswitch.id
    zone_id    = data.alicloud_zones.default.zones.0.id
  }
  zone_mappings {
    vswitch_id = alicloud_vswitch.vswitch_b.id
    zone_id    = data.alicloud_zones.default.zones.1.id
  }
}

resource "alicloud_nlb_server_group" "default" {
  server_group_name        = "http-server-group"
  server_group_type        = "Instance"
  vpc_id                   = alicloud_vpc.capstone_vpc.id
  scheduler                = "Rr"
  protocol                 = "TCP"
  connection_drain_timeout = 60
  address_ip_version       = "Ipv4"
  health_check {
    health_check_enabled         = true
    health_check_type            = "TCP"
    health_check_connect_port    = 0
    healthy_threshold            = 2
    unhealthy_threshold          = 2
    health_check_connect_timeout = 5
    health_check_interval        = 10
    http_check_method            = "GET"
    health_check_http_code       = ["http_2xx", "http_3xx", "http_4xx"]
  }
}

resource "alicloud_nlb_server_group_server_attachment" "default" {
    count = length(alicloud_instance.web-instance-test)
  server_type     = "Ecs"
  server_id       = alicloud_instance.web-instance-test[count.index].id
  port            = 80
  server_group_id = alicloud_nlb_server_group.default.id
  weight          = 100
}
resource "alicloud_nlb_listener" "default" {
  listener_protocol      = "TCP"
  listener_port          = "80"
  listener_description   = "http-listener"
  load_balancer_id       = alicloud_nlb_load_balancer.default.id
  server_group_id        = alicloud_nlb_server_group.default.id
  idle_timeout           = "900"
  cps                    = "0"
  mss                    = "0"
}

output "dns_name" {
    value = alicloud_nlb_load_balancer.default.dns_name
  
}
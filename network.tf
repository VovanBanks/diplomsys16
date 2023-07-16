#----------------- VPC -----------------------------
resource "yandex_vpc_network" "newnet" {
  name = "net_project"
  description  = "new network for the project"
}

resource "yandex_vpc_route_table" "inner-to-nat" {
  network_id = yandex_vpc_network.newnet.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.bastion.network_interface.0.ip_address
  }
}
#----------------- subnet -----------------------------
resource "yandex_vpc_subnet" "inner-nginx-1" {
  name           = "nginx-1-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.newnet.id
  v4_cidr_blocks = ["10.0.1.0/28"]
  route_table_id = yandex_vpc_route_table.inner-to-nat.id
}

resource "yandex_vpc_subnet" "inner-nginx-2" {
  name           = "nginx-2-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.newnet.id
  v4_cidr_blocks = ["10.0.2.0/28"]
  route_table_id = yandex_vpc_route_table.inner-to-nat.id
}

resource "yandex_vpc_subnet" "inner-services" {
  name           = "inner-services-subnet"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.newnet.id
  v4_cidr_blocks = ["10.0.3.0/27"]
  route_table_id = yandex_vpc_route_table.inner-to-nat.id
}

resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.newnet.id
  v4_cidr_blocks = ["10.0.4.0/27"]
}


#----------------- target_group -----------------
resource "yandex_alb_target_group" "new_tg_group" {
  name = "new-target-group"

  target {
    ip_address = yandex_compute_instance.nginx-1.network_interface.0.ip_address
    subnet_id  = yandex_vpc_subnet.inner-nginx-1.id
  }

  target {
    ip_address = yandex_compute_instance.nginx-2.network_interface.0.ip_address
    subnet_id  = yandex_vpc_subnet.inner-nginx-2.id
  }
}

#----------------- backend_group -----------------

resource "yandex_alb_backend_group" "new_alb_bg" {
  name = "new-backend-group"

  http_backend {
    name             = "http-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.new_tg_group.id]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      timeout             = "10s"
      interval            = "2s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}
#----------------- HTTP router -----------------
resource "yandex_alb_http_router" "new_router" {
  name = "new-http-router"
}

resource "yandex_alb_virtual_host" "root" {
  name           = "root-virtual-host"
  http_router_id = yandex_alb_http_router.new_router.id
  route {
    name = "root-path"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.new_alb_bg.id
        timeout          = "3s"
      }
    }
  }
}
#----------------- L7 balancer -----------------

resource "yandex_alb_load_balancer" "new_lb" {
  name               = "new-load-balancer"
  network_id         = yandex_vpc_network.newnet.id
  security_group_ids = [yandex_vpc_security_group.public-load-balancer.id, yandex_vpc_security_group.inner.id] 

  allocation_policy {
    location {
      zone_id   = "ru-central1-c"
      subnet_id = yandex_vpc_subnet.inner-services.id
    }
  }

  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.new_router.id
      }
    }
  }
}
#----------------- security_group -----------------
resource "yandex_vpc_security_group" "inner" {
  name       = "inner-rules"
  network_id = yandex_vpc_network.newnet.id

  ingress {
    protocol       = "ANY"
    description    = "allow any connection from inner subnets"
    v4_cidr_blocks = ["10.0.1.0/28", "10.0.2.0/28", "10.0.3.0/27", "10.0.4.0/27"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-bastion" {
  name       = "public-bastion-rules"
  network_id = yandex_vpc_network.newnet.id

  ingress {
    protocol       = "TCP"
    description    = "allow ssh connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-grafana" {
  name       = "public-grafana-rules"
  network_id = yandex_vpc_network.newnet.id

  ingress {
    protocol       = "TCP"
    description    = "allow grafana connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-kibana" {
  name       = "public-kibana-rules"
  network_id = yandex_vpc_network.newnet.id

  ingress {
    protocol       = "TCP"
    description    = "allow kibana connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-load-balancer" {
  name       = "public-load-balancer-rules"
  network_id = yandex_vpc_network.newnet.id

  ingress {
    protocol          = "ANY"
    description       = "Health checks"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol       = "TCP"
    description    = "allow HTTP connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

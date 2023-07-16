#----------------- inventory.ini -----------------
resource "local_file" "ansible-inventory" {
  content  = <<-EOT
    [bastion]
    ${yandex_compute_instance.bastion.network_interface.0.ip_address} public_ip=${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} 

    [web]
    ${yandex_compute_instance.nginx-1.network_interface.0.ip_address}
    ${yandex_compute_instance.nginx-2.network_interface.0.ip_address}

    [public-balancer]
    ${yandex_alb_load_balancer.new_lb.listener.0.endpoint.0.address.0.external_ipv4_address.0.address}

    [prometheus]
    ${yandex_compute_instance.prometheus.network_interface.0.ip_address}

    [grafana]
    ${yandex_compute_instance.grafana.network_interface.0.ip_address} public_ip=${yandex_compute_instance.grafana.network_interface.0.nat_ip_address} 

    [elastic]
    ${yandex_compute_instance.elastic.network_interface.0.ip_address}

    [kibana]
    ${yandex_compute_instance.kibana.network_interface.0.ip_address} public_ip=${yandex_compute_instance.kibana.network_interface.0.nat_ip_address} 

    [web:vars]
    domain="myproject"
    
    [all:vars]
    ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -p 22 -W %h:%p -q user@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
    EOT
  filename = "./inventory.ini"
}

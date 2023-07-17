resource "yandex_compute_snapshot_schedule" "default" {
  name = "default"

  schedule_policy {
    expression = "0 3 ? * *"
  }

  snapshot_count = 7

  snapshot_spec {
    description = "daily"
  }

  disk_ids = [yandex_compute_instance.nginx-1.boot_disk[0].disk_id,
              yandex_compute_instance.nginx-2.boot_disk[0].disk_id,
              yandex_compute_instance.bastion.boot_disk[0].disk_id,
              yandex_compute_instance.prometheus.boot_disk[0].disk_id,
              yandex_compute_instance.grafana.boot_disk[0].disk_id,
              yandex_compute_instance.elastic.boot_disk[0].disk_id,
              yandex_compute_instance.kibana.boot_disk[0].disk_id]
}

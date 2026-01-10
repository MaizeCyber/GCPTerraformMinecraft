resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "CPU Utilization < 10% for 30m"
  combiner     = "OR"

  conditions {
    display_name = "Idle CPU Check"
    condition_threshold {
      comparison      = "COMPARISON_LT"
      threshold_value = 0.1
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\" AND metric.labels.instance_name = \"minecraft-server-1\""
      duration        = "0s"

      aggregations {
        alignment_period   = "1800s"
        per_series_aligner = "ALIGN_MAX"
      }

      trigger {
        count = 1
      }
    }
  }
  notification_channels = [google_monitoring_notification_channel.pubsub_channel.name]
}
resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "CPU Utilization < 10%"
  documentation {
    content = "The $${metric.display_name} of the $${resource.type} $${resource.label.instance_id} in $${resource.project} has used less then 10% CPU Utilizatio over the last 30 minutes."
  }
  combiner     = "OR"
  conditions {
    display_name = "Condition 1"
    condition_threshold {
        comparison = "COMPARISON_GT"
        duration = "30m"
        filter = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\" AND instance_name = \"minecraft-server-1\""
        threshold_value = "50"
        trigger {
          count = "1"
        }
    }
  }

  alert_strategy {
    notification_channel_strategy {
        renotify_interval = "1800s"
        notification_channel_names = [google_monitoring_notification_channel.email.name]
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  user_labels = {
    severity = "warning"
  }
}

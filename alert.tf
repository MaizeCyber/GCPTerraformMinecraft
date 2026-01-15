resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "Server Empty"
  combiner     = "OR"

  conditions {
    display_name = "server empty for 60 seconds"
    condition_matched_log {
      filter = "logName=\"projects/minecraftserver-482021/logs/minecraft_log\"\njsonPayload.severity=\"INFO\"\njsonPayload.message=\"Server empty for 60 seconds, pausing\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
  notification_channels = [google_monitoring_notification_channel.pubsub_channel.name]
}
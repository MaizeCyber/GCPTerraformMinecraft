resource "google_pubsub_topic" "server_cpu_topic" {
  name = "server-cpu-alerts"
}

resource "google_monitoring_notification_channel" "pubsub_channel" {
  display_name = "PubSub Shutdown Channel"
  type         = "pubsub"
  labels = {
    topic = google_pubsub_topic.server_cpu_topic.id
  }
}
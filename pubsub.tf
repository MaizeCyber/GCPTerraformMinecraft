resource "google_pubsub_topic" "server_empty_topic" {
  name = "server-empty-alerts"
}

resource "google_monitoring_notification_channel" "pubsub_channel" {
  display_name = "PubSub Shutdown Channel"
  type         = "pubsub"
  labels = {
    topic = google_pubsub_topic.server_empty_topic.id
  }
}
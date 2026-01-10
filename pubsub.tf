resource "google_pubsub_topic" "server-cpu-topic" {
  name = "pubsub-topic"
}

resource "google_monitoring_notification_channel" "pubsub_channel" {
  display_name = "PubSub Shutdown Channel"
  type         = "pubsub"
  labels = {
    topic = google_pubsub_topic.server-cpu-topic.id
  }
}
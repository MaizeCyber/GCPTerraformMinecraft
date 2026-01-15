from __future__ import annotations

import sys
import os

from google.cloud import compute_v1
import functions_framework
from cloudevents.http import CloudEvent

project_id = os.environ['PROJECT_NAME']
zone = os.environ['PROJECT_ZONE']
instance_name = os.environ['INSTANCE_NAME']

def send_instance_start():
    instance_client = compute_v1.InstancesClient()
    try:
        instance_client.suspend(project=project_id, zone=zone, instance=instance_name)
        print("Instance suspend sent")
    except Exception as e:
        print(f"Could not send instance suspend: {str(e)}", file=sys.stderr)
    return 0

@functions_framework.cloud_event
def handle_eventarc_trigger(cloud_event: CloudEvent):
    data = cloud_event.data

    # Metadata is accessible via keys
    event_id = cloud_event["id"]
    event_type = cloud_event["type"]

    print(f"Received event ID: {event_id} of type {event_type}")
    print(f"Event Data: {data}")
    send_instance_start()

    return "OK", 200
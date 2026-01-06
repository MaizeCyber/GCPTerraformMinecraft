from __future__ import annotations

import json
import os
import sys
from typing import Any
import proto

import threading

from google.api_core.extended_operation import ExtendedOperation
from google.cloud import compute_v1

from flask import abort
from flask import request
from flask import Flask

server_ip = os.environ['SERVER_IP']
project_id = os.environ['PROJECT_NAME']
zone = os.environ['PROJECT_ZONE']
instance_name = os.environ['INSTANCE_NAME']
network_name = os.environ['NETWORK_NAME']

def get_instance(project_id: str = project_id, zone: str = zone, instance_name: str = instance_name) -> None:
    """
    Starts a stopped Google Compute Engine instance (with unencrypted disks).
    Args:
        project_id: project ID or project number of the Cloud project your instance belongs to.
        zone: name of the zone your instance belongs to.
        instance_name: name of the instance your want to start.
    """
    instance_client = compute_v1.InstancesClient()

    operation = instance_client.get(
        project=project_id, zone=zone, instance=instance_name
    )

    status_dict = json.loads(proto.Message.to_json(operation))
    return (status_dict)

def send_instance_start():
    instance_client = compute_v1.InstancesClient()
    instance_client.start(project=project_id, zone=zone, instance=instance_name)
    return 0

def start_instance() -> None:
    """
    Starts a stopped Google Compute Engine instance (with unencrypted disks).
    """
    instance_client = compute_v1.InstancesClient()
    try:
        status = get_instance()
        if status.get('status') == "TERMINATED":
            thread = threading.Thread(target=send_instance_start)
            thread.start()
            return "Server Starting!"
        else:
            return f"Current server status: {status.get('status')}"
    except:
        return "Error: Server status could not be found"

def create_firewall_rule(
        visitor_ip: str, firewall_rule_name: str, project_id: str = project_id,
        network: str = f"global/networks/{network_name}"
) -> compute_v1.Firewall:
    """
    Creates a simple firewall rule allowing for incoming HTTP and HTTPS access from the entire Internet.

    Args:
        project_id: project ID or project number of the Cloud project you want to use.
        firewall_rule_name: name of the rule that is created.
        network: name of the network the rule will be applied to. Available name formats:
            * https://www.googleapis.com/compute/v1/projects/{project_id}/global/networks/{network}
            * projects/{project_id}/global/networks/{network}
            * global/networks/{network}
        visitor_ip: IP address to be whitelisted

    Returns:
        compute_v1.Firewall: A Firewall object.
    """
    firewall_rule = compute_v1.Firewall()
    firewall_rule.name = firewall_rule_name
    firewall_rule.direction = "INGRESS"

    allowed_ports = compute_v1.Allowed()
    allowed_ports.I_p_protocol = "tcp"
    allowed_ports.ports = ["25565"]

    firewall_rule.allowed = [allowed_ports]
    firewall_rule.source_ranges = [f"{visitor_ip}/32"]
    firewall_rule.network = network
    firewall_rule.description = f"Allowing TCP traffic on port 25565 from {visitor_ip}."

    firewall_rule.target_tags = ["minecraft-server"]

    # Note that the default value of priority for the firewall API is 1000.
    # If you check the value of `firewall_rule.priority` at this point it
    # will be equal to 0, however it is not treated as "set" by the library and thus
    # the default will be applied to the new rule. If you want to create a rule that
    # has priority == 0, you need to explicitly set it so:

    # firewall_rule.priority = 0

    firewall_client = compute_v1.FirewallsClient()
    operation = firewall_client.insert(
        project=project_id, firewall_resource=firewall_rule
    )

    print(operation)

    return firewall_client.get(project=project_id, firewall=firewall_rule_name)


app = Flask(__name__)

@app.route("/")
def server_information():

    if request.access_route:
        visitor_ip = request.access_route[0]
    else:
        # Fallback for local development
        visitor_ip = request.remote_addr
    ip_string = visitor_ip.replace(".","-")
    create_firewall_rule(firewall_rule_name=f"client-allow-{ip_string}", visitor_ip=visitor_ip)
    print(f"Logged Visitor IP: {visitor_ip}")

    server_status = start_instance()
    return f"<p>IP whitelisted. {server_status}</p>"

if __name__ == "__main__":
    # Cloud Run provides the PORT environment variable
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
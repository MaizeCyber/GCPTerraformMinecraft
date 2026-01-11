import logging
import socket
import threading

""" Function lifted from https://github.com/Tardsquad/tardsquad-discord-bot/blob/main/tardsquad_discord_bot/gcp_port.py"""

def start_server(port):
    sock = socket.socket()
    sock.bind(("", port))
    sock.listen(8)
    while True:
        conn, addr = sock.accept()
        conn.send(
            (
                "Thank you for connecting, but we're only listening here because Google Cloud Run "
                "requires us to do. Nothing to do...\n"
            ).encode()
        )
        conn.close()


def start_gcp_port(port):
    """Listen on a given TCP port in a separate thread.

    This is really a dummy TCP listener needed because Google Cloud Run requires the service
    to listen to the from envionment specified $PORT.
    Reference: https://emilwypych.com/2020/10/25/how-to-run-discord-bot-on-cloud-run/
    """

    daemon = threading.Thread(name="daemon_server", target=start_server, args=(port,), daemon=True)
    daemon.start()
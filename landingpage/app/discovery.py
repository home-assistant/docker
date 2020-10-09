import logging
import socket
import time

import zeroconf

ZEROCONF_TYPE = "_home-assistant._tcp.local."
_LOGGER = logging.getLogger(__name__)


def start_discovery():
    host_ip = None
    while host_ip is None:
        try:
            host_ip = get_local_ip()
        except socket.gaierror:
            time.sleep(5)

    zc = zeroconf.Zeroconf()

    tries = 0
    name_suffix = ""
    while True:
        try:
            register_service(zc, host_ip, name_suffix)
            break
        except zeroconf.NonUniqueNameException:
            tries += 1
            name_suffix = f"_{tries}"

    return zc.close


def register_service(zc: zeroconf.Zeroconf, host_ip: str, name_suffix: str):
    host_url = f"http://{host_ip}:8123"
    params = {
        "location_name": "Home Assistant",
        "uuid": "",
        "version": "0.0.0",
        "external_url": "",
        "internal_url": host_url,
        "base_url": host_url,  # Always needs authentication
        "requires_api_password": True,
    }

    try:
        host_ip_pton = socket.inet_pton(socket.AF_INET, host_ip)
    except OSError:
        host_ip_pton = socket.inet_pton(socket.AF_INET6, host_ip)

    info = zeroconf.ServiceInfo(
        ZEROCONF_TYPE,
        name=f"homeassistant{name_suffix}.{ZEROCONF_TYPE}",
        server="homeassistant.local.",
        addresses=[host_ip_pton],
        port=8123,
        properties=params,
    )

    _LOGGER.info("Starting Zeroconf broadcast")

    try:
        zc.register_service(info)
    except zeroconf.NonUniqueNameException:
        _LOGGER.error(
            "Home Assistant instance with identical name present in the local network"
        )


def get_local_ip() -> str:
    """Try to determine the local IP address of the machine."""
    sock = None

    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

        # Use Google Public DNS server to determine own IP
        sock.connect(("8.8.8.8", 80))

        return sock.getsockname()[0]  # type: ignore
    except OSError:
        return socket.gethostbyname(socket.gethostname())
    finally:
        if sock is not None:
            sock.close()

from . import http, discovery


def run():
    stop_discovery = discovery.start_discovery()
    http.serve_forever()
    stop_discovery()

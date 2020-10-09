import json
from aiohttp import web
import pathlib

PUBLIC_PATH = pathlib.Path(__file__).parent / "public"


def serve_forever():
    app = web.Application()

    for path in PUBLIC_PATH.iterdir():
        if path.name == "index.html":
            continue

        app.add_routes(
            [
                web.StaticDef("/landingpage/", PUBLIC_PATH, {}),
                web.route(
                    "*",
                    r"/api/{path:.*}",
                    lambda req: web.Response(status=403),
                ),
                web.get(
                    r"/{path:.*}",
                    lambda req: web.FileResponse(PUBLIC_PATH / "index.html"),
                ),
            ]
        )

    web.run_app(app)

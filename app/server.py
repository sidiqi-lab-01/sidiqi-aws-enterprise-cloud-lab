from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import json
import mimetypes
import os

APP_DIR = Path(__file__).resolve().parent
STATIC_DIR = APP_DIR / "static"

APP_NAME = "AWS Enterprise Cloud Lab"
APP_VERSION = os.getenv("APP_VERSION", "development")
APP_ENVIRONMENT = os.getenv("APP_ENVIRONMENT", "production")
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
PORT = int(os.getenv("PORT", "8080"))


class LabHandler(BaseHTTPRequestHandler):

    def send_json(self, data, status=200):
        body = json.dumps(data).encode("utf-8")

        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()

        self.wfile.write(body)

    def serve_file(self, path):
        if not path.exists() or not path.is_file():
            self.send_error(404)
            return

        content = path.read_bytes()
        content_type, _ = mimetypes.guess_type(path.name)

        self.send_response(200)
        self.send_header(
            "Content-Type",
            content_type or "application/octet-stream"
        )
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()

        self.wfile.write(content)

    def do_GET(self):

        if self.path == "/health":
            self.send_json({
                "status": "healthy",
                "service": "aws-enterprise-cloud-lab",
                "version": APP_VERSION
            })
            return

        if self.path == "/api/version":
            self.send_json({
                "name": APP_NAME,
                "version": APP_VERSION
            })
            return

        if self.path == "/api/status":
            self.send_json({
                "application": {
                    "name": APP_NAME,
                    "status": "healthy",
                    "version": APP_VERSION
                },
                "deployment": {
                    "environment": APP_ENVIRONMENT,
                    "platform": "AWS",
                    "region": AWS_REGION,
                    "runtime": "Docker"
                },
                "architecture": {
                    "dns": "Amazon Route 53",
                    "tls": "AWS Certificate Manager",
                    "load_balancer": "Application Load Balancer",
                    "compute": "Amazon EC2 Auto Scaling",
                    "container_registry": "Amazon ECR",
                    "infrastructure_as_code": "Terraform"
                }
            })
            return

        if self.path == "/":
            self.serve_file(STATIC_DIR / "index.html")
            return

        if self.path.startswith("/static/"):
            relative = self.path.removeprefix("/static/")
            requested = (STATIC_DIR / relative).resolve()

            try:
                requested.relative_to(STATIC_DIR.resolve())
            except ValueError:
                self.send_error(403)
                return

            self.serve_file(requested)
            return

        self.send_json({"error": "not found"}, status=404)

    def log_message(self, format, *args):
        print(
            "%s - - [%s] %s"
            % (
                self.client_address[0],
                self.log_date_time_string(),
                format % args,
            )
        )


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", PORT), LabHandler)

    print(f"{APP_NAME} {APP_VERSION}")
    print(f"Listening on 0.0.0.0:{PORT}")

    server.serve_forever()

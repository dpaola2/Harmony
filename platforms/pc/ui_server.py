"""Loopback-only visual prototype. No audio, Bluetooth, or device access."""
import argparse
import json
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

from core.models import Track
from core.ui_prototype import PrototypeUI


ASSETS = Path(__file__).with_name('ui')


def make_server(port=8766):
    tracks = [Track(**entry) for entry in json.loads((ASSETS / 'trial-library.json').read_text())]
    app = PrototypeUI(tracks)
    last_tick = [time.monotonic()]

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *_args):
            pass

        def reply(self, data, content_type='application/json', status=200):
            self.send_response(status)
            self.send_header('Content-Type', content_type)
            self.send_header('Content-Length', str(len(data)))
            self.send_header('Cache-Control', 'no-store')
            self.send_header('X-Content-Type-Options', 'nosniff')
            self.end_headers()
            self.wfile.write(data)

        def state(self):
            now = time.monotonic()
            app.action('tick', now - last_tick[0])
            last_tick[0] = now

        def do_GET(self):
            if self.path == '/api/state':
                self.state()
                self.reply(json.dumps(app.snapshot()).encode())
                return
            assets = {'/': ('index.html', 'text/html; charset=utf-8'),
                      '/app.js': ('app.js', 'text/javascript; charset=utf-8'),
                      '/style.css': ('style.css', 'text/css; charset=utf-8')}
            if self.path not in assets:
                self.reply(b'Not found', 'text/plain', 404)
                return
            filename, content_type = assets[self.path]
            self.reply((ASSETS / filename).read_bytes(), content_type)

        def do_POST(self):
            # A local page may operate this simulation; other origins may not.
            origin = self.headers.get('Origin')
            expected = 'http://' + self.headers.get('Host', '')
            if origin and origin != expected:
                self.reply(b'Forbidden', 'text/plain', 403)
                return
            if self.path != '/api/action':
                self.reply(b'Not found', 'text/plain', 404)
                return
            try:
                size = int(self.headers.get('Content-Length', '0'))
                if not 0 < size <= 1024:
                    raise ValueError('Invalid request size')
                request = json.loads(self.rfile.read(size))
                name, value = request.get('name'), request.get('value')
                if name not in ('rotate', 'select', 'back', 'play_pause', 'previous', 'next', 'home', 'row'):
                    raise ValueError('Unknown action')
                if name in ('rotate', 'row') and (type(value) is not int or abs(value) > 1000):
                    raise ValueError('Invalid value')
                self.state()
                app.action(name, value)
                self.reply(json.dumps(app.snapshot()).encode())
            except (ValueError, TypeError, AttributeError):
                self.reply(b'Invalid request', 'text/plain', 400)

    return HTTPServer(('127.0.0.1', port), Handler)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--port', type=int, default=8766)
    server = make_server(parser.parse_args().port)
    print('Harmony UI prototype: http://127.0.0.1:%s' % server.server_port, flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == '__main__':
    main()

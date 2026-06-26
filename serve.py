import http.server
import socketserver

PORT = 8080
Handler = http.server.SimpleHTTPRequestHandler

# Force correct MIME types on Windows
Handler.extensions_map.update({
    '.js': 'application/javascript',
    '.wasm': 'application/wasm',
    '.json': 'application/json',
    '.css': 'text/css',
    '.html': 'text/html',
    '.otf': 'font/otf',
    '.ttf': 'font/ttf',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2',
})

class MyTCPServer(socketserver.TCPServer):
    allow_reuse_address = True

with MyTCPServer(("127.0.0.1", PORT), Handler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()

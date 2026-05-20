# org.nginx:1.0

TOSCA profile for [nginx](https://nginx.org), the HTTP server and
reverse proxy.

## Node types

- **WebServer** — installation of the nginx web server (apt package
  `nginx`).
- **WebSite** — a website hosted on a `WebServer`.

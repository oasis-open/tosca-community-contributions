# org.wordpress:1.0

TOSCA profile for [WordPress](https://wordpress.org), the
open-source content management system.

## Node types

- **Wordpress** — a WordPress website. Derives from the
  `org.nginx:1.0` `WebSite` type, since a WordPress installation is
  itself a website served by nginx. The create operation downloads
  the WordPress tarball from `wordpress.org` (configurable via the
  `wordpress_url` property) and extracts it into the web server's
  document root.

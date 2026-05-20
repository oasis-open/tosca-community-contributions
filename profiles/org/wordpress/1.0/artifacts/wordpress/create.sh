#!/bin/bash
set -euo pipefail

init_output() {
    exec 3>&1
    exec >> "$LOG_FILE" 2>&1
    output() { echo "$@" >&3; }
}

init_output

: "${wordpress_url:=https://wordpress.org/latest.tar.gz}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

echo "Downloading WordPress from $wordpress_url"
curl -fsSL "$wordpress_url" -o "$WORK_DIR/wordpress.tar.gz"
tar -xzf "$WORK_DIR/wordpress.tar.gz" -C "$WORK_DIR"

sudo mkdir -p /var/www/html
sudo rsync -av "$WORK_DIR/wordpress/" /var/www/html/

sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html/ -type d -exec chmod 755 {} \;
sudo find /var/www/html/ -type f -exec chmod 644 {} \;

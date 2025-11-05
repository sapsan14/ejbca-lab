#!/bin/bash
set -e

# Авто-домен через nip.io
DOMAIN="${HOSTNAME}.nip.io"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@example.com}"

# Обновляем пакеты
apt-get update
apt-get install -y ca-certificates curl jq git apt-transport-https lsb-release gnupg

# Устанавливаем Docker
curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu || true

# Устанавливаем Docker Compose v2
apt-get install -y docker-compose-plugin

# Создаём директорию приложения
mkdir -p /opt/ejbca && cd /opt/ejbca

# Создаём docker-compose.yml
cat > docker-compose.yml <<'YAML'
version: "3.8"
services:
  database:
    image: mariadb:10.11
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ChangeMeRootPass!
      MYSQL_DATABASE: ejbca
      MYSQL_USER: ejbca
      MYSQL_PASSWORD: ejbcapwd
    volumes:
      - dbdata:/var/lib/mysql

  ejbca:
    image: primekey/ejbca-ce:latest
    restart: unless-stopped
    depends_on:
      - database
    environment:
      DATABASE_JDBC_URL: jdbc:mariadb://database:3306/ejbca?characterEncoding=UTF-8
      DATABASE_USER: ejbca
      DATABASE_PASSWORD: ejbcapwd
      TLS_SETUP_ENABLED: "simple"
    ports:
      - "8080:8080"
      - "8443:8443"
    volumes:
      - ejbca-data:/opt/ejbca

  caddy:
    image: caddy:2
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - caddy_data:/data
      - caddy_config:/config
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
    depends_on:
      - ejbca

volumes:
  dbdata:
  ejbca-data:
  caddy_data:
  caddy_config:
YAML

# Создаём Caddyfile для HTTPS и проксирования на EJBCA
cat > Caddyfile <<'CADDY'
${DOMAIN} {
    reverse_proxy ejbca:8443 {
        transport http {
            tls_insecure_skip_verify
        }
    }
    encode zstd gzip
}
CADDY

# Права на папку
chown -R ubuntu:ubuntu /opt/ejbca

# Поднимаем стек
/usr/bin/docker compose up -d

echo "EJBCA stack started. Domain: ${DOMAIN}" > /opt/ejbca/started.txt

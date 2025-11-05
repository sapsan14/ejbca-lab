# Container Deployment: EJBCA with Docker/Podman

Quick deployment guide for running EJBCA using Docker or Podman with docker-compose.

## 📋 Overview

This method provides the fastest way to get EJBCA up and running. It uses containerized services for both EJBCA and its database, making it ideal for:
- Development and testing
- Learning EJBCA
- Quick deployments
- Local labs and demonstrations

### Components

- **EJBCA:** PrimeKey EJBCA Community Edition (latest)
- **Database:** MariaDB 10.11
- **Orchestration:** docker-compose

## 🎯 Prerequisites

- Docker or Podman installed
- docker-compose (or `podman-compose`) installed
- At least 4GB available RAM
- 10GB+ free disk space
- Ports 8080 and 8443 available

## 🚀 Quick Start

### Option 1: Using Docker

1. **Clone or navigate to the project directory:**

```bash
cd docker-podman
```

2. **Start the services:**

```bash
docker-compose up -d
```

3. **Check service status:**

```bash
docker-compose ps
```

4. **View logs:**

```bash
docker-compose logs -f ejbca
```

### Option 2: Using Podman

1. **Navigate to the project directory:**

```bash
cd docker-podman
```

2. **Start the services:**

```bash
podman-compose up -d
```

3. **Check service status:**

```bash
podman-compose ps
```

4. **View logs:**

```bash
podman-compose logs -f ejbca
```

## 📁 Configuration

### Environment Variables

The `docker-compose.yml` file configures the following:

#### Database Configuration
- **Database:** `ejbca`
- **User:** `ejbca`
- **Password:** `ejbcapass` (⚠️ Change in production!)
- **Root Password:** `rootpass` (⚠️ Change in production!)

#### EJBCA Configuration
- **CA Name:** `ManagementCA`
- **Database Host:** `db` (internal container name)
- **Database Port:** `3306`
- **Database Name:** `ejbca`

### Ports

| Port | Service | Description |
|------|---------|-------------|
| 8080 | HTTP | EJBCA HTTP interface (bound to localhost) |
| 8443 | HTTPS | EJBCA HTTPS interface (bound to localhost) |

**Note:** Ports are bound to `127.0.0.1` for security. To expose them publicly, modify the port mapping in `docker-compose.yml`.

### Volumes

The following volumes are created:

- `ejbca-db-data` - Persistent MariaDB data storage
- Container network: `ejbca-net` - Internal network for service communication

## 🔍 Verification

### Check Container Status

```bash
# Docker
docker-compose ps

# Podman
podman-compose ps
```

Expected output should show both `ejbca` and `ejbca-db` containers as `Up`.

### Check Health

EJBCA includes a health check endpoint. Verify it's working:

```bash
curl -f http://localhost:8080/ejbca/publicweb/healthcheck/ejbcahealth
```

### Access Web Interfaces

Once the containers are running, access EJBCA web interfaces:

- **Administration Interface:** https://127.0.0.1:8443/ejbca/adminweb
- **RA (Registration Authority) Interface:** https://127.0.0.1:8443/ejbca/ra
- **Public Web Interface:** https://127.0.0.1:8443/ejbca/publicweb

⚠️ **Note:** You may need to accept the self-signed certificate in your browser.

### View Logs

Monitor container logs:

```bash
# Docker
docker-compose logs -f ejbca
docker-compose logs -f db

# Podman
podman-compose logs -f ejbca
podman-compose logs -f db
```

## 🔧 Management Commands

### Start Services

```bash
# Docker
docker-compose up -d

# Podman
podman-compose up -d
```

### Stop Services

```bash
# Docker
docker-compose stop

# Podman
podman-compose stop
```

### Restart Services

```bash
# Docker
docker-compose restart

# Podman
podman-compose restart
```

### Remove Services (Keep Data)

```bash
# Docker
docker-compose down

# Podman
podman-compose down
```

### Remove Services and Data

⚠️ **Warning:** This will delete all EJBCA data!

```bash
# Docker
docker-compose down -v

# Podman
podman-compose down -v
```

## 💾 Backup and Restore

### Backup Database Volume

#### Using Docker

```bash
docker run --rm \
  -v ejbca-lab_ejbca-db-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/ejbca-db-backup-$(date +%Y%m%d).tar.gz -C /data .
```

#### Using Podman

```bash
podman run --rm \
  -v ejbca-lab_ejbca-db-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/ejbca-db-backup-$(date +%Y%m%d).tar.gz -C /data .
```

### Restore Database Volume

#### Using Docker

```bash
docker run --rm \
  -v ejbca-lab_ejbca-db-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/ejbca-db-backup-YYYYMMDD.tar.gz -C /data
```

#### Using Podman

```bash
podman run --rm \
  -v ejbca-lab_ejbca-db-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/ejbca-db-backup-YYYYMMDD.tar.gz -C /data
```

Replace `YYYYMMDD` with the actual backup date.

## 🔐 Security Considerations

### Default Credentials

⚠️ **Important:** The default credentials in this configuration are for **testing only**:

- Database root password: `rootpass`
- Database user password: `ejbcapass`
- EJBCA admin: Check EJBCA documentation for default credentials

**Before production use:**
1. Change all passwords
2. Use environment variables or secrets management
3. Restrict network access
4. Use proper SSL/TLS certificates

### Securing Configuration

#### Option 1: Environment File

Create a `.env` file:

```bash
cat > .env <<EOF
DB_ROOT_PASSWORD=YourStrongRootPassword
DB_PASSWORD=YourStrongPassword
EJBCA_CA_NAME=YourCAName
EOF
```

Modify `docker-compose.yml` to use environment variables:

```yaml
environment:
  MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
  MYSQL_PASSWORD: ${DB_PASSWORD}
  CA_NAME: ${EJBCA_CA_NAME}
```

#### Option 2: Docker Secrets (Docker Swarm)

For production deployments, consider using Docker Swarm secrets.

### Network Security

By default, ports are bound to `127.0.0.1` (localhost only). To expose publicly:

1. Change port bindings in `docker-compose.yml`
2. Configure firewall rules
3. Use a reverse proxy (nginx, Traefik, etc.)
4. Implement proper SSL/TLS certificates

## 🐛 Troubleshooting

### Containers Won't Start

1. **Check ports are available:**
```bash
sudo ss -tlnp | grep -E '8080|8443|3306'
```

2. **Check disk space:**
```bash
df -h
```

3. **Check Docker/Podman is running:**
```bash
# Docker
docker ps

# Podman
podman ps
```

### Database Connection Issues

1. **Check database container is running:**
```bash
docker-compose ps db
```

2. **View database logs:**
```bash
docker-compose logs db
```

3. **Test database connection:**
```bash
docker-compose exec db mysql -u ejbca -pejbcapass ejbca
```

### EJBCA Health Check Fails

1. **Wait for initialization:** EJBCA may take several minutes to initialize
2. **Check logs for errors:**
```bash
docker-compose logs ejbca | tail -50
```

3. **Verify database is ready:**
```bash
docker-compose exec db mysql -u ejbca -pejbcapass -e "SHOW DATABASES;"
```

### Container Restart Issues

If containers keep restarting:

1. **Check logs:**
```bash
docker-compose logs --tail=100
```

2. **Check resource limits:**
```bash
docker stats
```

3. **Verify environment variables:**
```bash
docker-compose config
```

## 📊 Monitoring

### Resource Usage

```bash
# Docker
docker stats

# Podman
podman stats
```

### Container Logs

```bash
# Docker
docker-compose logs -f --tail=100

# Podman
podman-compose logs -f --tail=100
```

## 🔄 Updating

### Update EJBCA Container

```bash
# Pull latest image
docker-compose pull ejbca

# Restart service
docker-compose up -d ejbca
```

### Update Database Container

⚠️ **Warning:** Database updates should be done carefully with backups!

```bash
# Backup first!
# Then pull and restart
docker-compose pull db
docker-compose up -d db
```

## 📚 Additional Resources

- [EJBCA Documentation](https://doc.primekey.com/ejbca)
- [Docker Documentation](https://docs.docker.com/)
- [Podman Documentation](https://docs.podman.io/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [MariaDB Docker Image](https://hub.docker.com/_/mariadb)

## 🆘 Support

For issues:

1. Check container logs
2. Review EJBCA documentation
3. Check Docker/Podman documentation
4. Review troubleshooting section above

---

**Happy containerizing! 🐳**


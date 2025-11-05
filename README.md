# EJBCA Installation Lab

A comprehensive laboratory project for installing and deploying **EJBCA (Enterprise JavaBeans Certificate Authority)** using various methods and deployment scenarios.

## 📋 Overview

This lab provides step-by-step instructions and configurations for deploying EJBCA, a full-featured PKI (Public Key Infrastructure) solution, using multiple installation methods:

- 🖥️ **Manual Installation** - Traditional installation on Ubuntu with MariaDB and SoftHSM
- 🐳 **Container Deployment** - Docker/Podman-based deployment with docker-compose
- ☁️ **Cloud Deployment** - Automated deployment on Google Cloud Platform using Terraform

## 🎯 What is EJBCA?

EJBCA is an enterprise-grade Certificate Authority (CA) software that provides:
- Certificate lifecycle management
- Multiple certificate profiles (SSL/TLS, code signing, S/MIME, etc.)
- Support for Hardware Security Modules (HSM)
- Web-based administration interface
- REST API for automation
- eIDAS compliance support

## 📚 Installation Methods

### 1. Manual Installation
**Location:** [`manual-installation/`](manual-installation/)

Complete manual installation guide for EJBCA 9.2.0 on Ubuntu with:
- OpenJDK 17
- WildFly 35.0.1.Final
- MariaDB 10.11
- SoftHSM2 for hardware token simulation

**Best for:** Learning the installation process, custom configurations, production deployments

[→ View Manual Installation Guide](manual-installation/README.md)

### 2. Container Deployment (Docker/Podman)
**Location:** [`docker-podman/`](docker-podman/)

Quick deployment using containers with docker-compose:
- MariaDB 10.11 database container
- EJBCA Community Edition container
- Automatic health checks
- Persistent data volumes

**Best for:** Development, testing, quick deployments, local labs

[→ View Container Deployment Guide](docker-podman/README.md)

### 3. Cloud Deployment (Google Cloud Platform)
**Location:** [`terraform-lab/`](terraform-lab/)

Automated infrastructure deployment on GCP using Terraform:
- VM instance with automatic setup
- Static IP reservation
- Firewall rules configuration
- Optional reverse proxy with Caddy
- Support for both EJBCA and Smallstep CA

**Best for:** Cloud deployments, scalable infrastructure, infrastructure as code

[→ View Terraform Deployment Guide](terraform-lab/README.md)

## 🚀 Quick Start

### Prerequisites

- **For Manual Installation:** Ubuntu 22.04+, root/sudo access
- **For Container Deployment:** Docker or Podman, docker-compose
- **For Cloud Deployment:** Google Cloud account, Terraform, gcloud CLI

### Choose Your Method

1. **Quick local testing:** Use [Container Deployment](docker-podman/)
2. **Learning EJBCA internals:** Use [Manual Installation](manual-installation/)
3. **Production-like cloud setup:** Use [Terraform Deployment](terraform-lab/)

## 📖 Version Information

- **EJBCA Version:** 9.2.0 (EE with eIDAS support)
- **WildFly Version:** 35.0.1.Final
- **Java Version:** OpenJDK 17
- **Database:** MariaDB 10.11
- **Container Image:** `primekey/ejbca-ce:latest`

## 🔐 Security Notes

⚠️ **Important Security Considerations:**

- All default passwords in this lab are for **testing purposes only**
- **Change all default credentials** before deploying to production
- Use strong passwords for database and EJBCA admin accounts
- Configure firewall rules appropriately
- Consider using HSM for production deployments
- Regularly update EJBCA and dependencies

## 📁 Project Structure

```
ejbca-lab/
├── README.md                    # This file
├── manual-installation/         # Manual installation guide
│   └── README.md
├── docker-podman/              # Container deployment
│   ├── README.md
│   └── docker-compose.yml
└── terraform-lab/              # GCP Terraform deployment
    ├── README.md
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── startup.sh
```

## 🧪 Testing & Verification

After installation, verify EJBCA is running:

```bash
# Check web interface
curl -k https://localhost:8443/ejbca/publicweb/healthcheck/ejbcahealth

# Access admin web interface
# https://localhost:8443/ejbca/adminweb
```

## 📚 Additional Resources

- [EJBCA Official Documentation](https://doc.primekey.com/ejbca)
- [EJBCA Community Edition GitHub](https://github.com/Keyfactor/ejbca-ce)
- [WildFly Documentation](https://www.wildfly.org/documentation/)
- [MariaDB Documentation](https://mariadb.com/docs/)

## 🤝 Contributing

Feel free to improve this lab by:
- Adding more deployment methods
- Documenting additional configurations
- Fixing issues or improving documentation
- Adding troubleshooting guides

## 📝 License

This lab is provided for educational and testing purposes. EJBCA has its own licensing terms. Please refer to the official EJBCA documentation for licensing information.

## ⚠️ Disclaimer

This lab is intended for educational and testing purposes. For production deployments, please:
- Review security best practices
- Use appropriate hardware and resources
- Follow EJBCA production deployment guidelines
- Consult with security professionals

---

**Happy PKI Building! 🔐**

# Cloud Deployment: EJBCA on Google Cloud Platform with Terraform

Automated infrastructure deployment guide for EJBCA on Google Cloud Platform using Terraform and Docker.

## 📋 Overview

This guide provides complete infrastructure-as-code deployment of EJBCA on Google Cloud Platform. It includes automated VM creation, firewall configuration, and containerized EJBCA deployment.

### Features

- 🌐 **Static IP reservation** for consistent access
- 🔥 **Automated firewall rules** for SSH, HTTP, HTTPS, and EJBCA ports
- 🚀 **VM with startup script** that automatically installs Docker and deploys EJBCA
- 🔄 **Caddy reverse proxy** for HTTPS termination with automatic SSL
- 🎯 **Support for both EJBCA and Smallstep CA**

### Components

- **Infrastructure:** Google Cloud Platform (GCP)
- **Orchestration:** Terraform
- **Application:** EJBCA Community Edition (or Smallstep CA)
- **Database:** MariaDB 10.11 (containerized)
- **Reverse Proxy:** Caddy 2
- **VM Image:** Ubuntu 22.04 LTS

## 🎯 Prerequisites

- Google Cloud account with activated **Free Tier** or billing enabled
- Basic knowledge of Linux, SSH, Docker, and Terraform
- Installed tools: `git`, `terraform`, `gcloud`, `docker`
- SSH key pair for VM access
- Estimated budget: **€0-5/month** (free tier eligible if resources are stopped when not in use)

## 🛠️ Tool Installation

### 1. Google Cloud SDK

Install Google Cloud SDK:

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
sudo apt update && sudo apt install -y google-cloud-sdk
```

**Authenticate:**

```bash
gcloud init
```

Follow the prompts to authenticate and select/create a project.

### 2. Terraform

Install Terraform:

```bash
sudo apt-get update && sudo apt-get install -y wget unzip
wget https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
unzip terraform_1.9.8_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform -version
```

### 3. Docker and Compose

Install Docker:

```bash
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker && sudo systemctl start docker
```

### 4. Git

Install Git:

```bash
sudo apt install -y git
```

## ☁️ Google Cloud Setup

### Create or Select Project

Create a new project:

```bash
gcloud projects create my-pki-lab
gcloud config set project my-pki-lab
```

Or select an existing project:

```bash
gcloud config set project YOUR_PROJECT_ID
```

### Enable Required APIs

Enable Compute Engine API:

```bash
gcloud services enable compute.googleapis.com
```

### Verify Authentication

Check authentication:

```bash
gcloud auth list
```

### Set Billing (if needed)

If using free tier, ensure billing account is linked (no charges for free tier resources):

```bash
gcloud billing accounts list
gcloud billing projects link YOUR_PROJECT_ID --billing-account=BILLING_ACCOUNT_ID
```

## 🏗️ Terraform Deployment

### Configuration Files

The Terraform configuration includes:

- `main.tf` - Main infrastructure configuration
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values (IP address, domain)
- `startup.sh` - VM initialization script
- `terraform.tfvars` - Your specific configuration values

### Configure Variables

Edit `terraform.tfvars` with your values:

```hcl
project      = "my-pki-lab"
region       = "us-central1"        # or "europe-north1" for free tier
zone         = "us-central1-a"      # Match your region
machine_type = "e2-micro"           # Free tier eligible
ssh_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..." # Your public SSH key
ca_type      = "ejbca"              # "ejbca" or "step"
admin_email  = "your-email@example.com"
```

**Generate SSH key (if needed):**

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
cat ~/.ssh/id_ed25519.pub
```

### Choose CA Type

Before deploying, decide which CA to use:

- **`ejbca`** - EJBCA Community Edition (requires 2GB+ RAM, 2+ vCPUs recommended)
- **`step`** - Smallstep CA (lightweight, works with 512MB RAM)

**Tips:**
- For VMs with ≤1 GB RAM, use `step`
- For full EJBCA on GCP, use at least `e2-medium` (2GB RAM, 2 vCPUs)
- Free tier `e2-micro` may work for EJBCA but can be slow

### Deploy Infrastructure

1. **Initialize Terraform:**

```bash
cd terraform-lab
terraform init
```

2. **Review the deployment plan:**

```bash
terraform plan
```

3. **Deploy infrastructure:**

```bash
terraform apply
```

Type `yes` when prompted, or use:

```bash
terraform apply -auto-approve
```

4. **Wait for deployment** (usually 2-5 minutes)

### Get Deployment Information

After deployment, get the IP address and domain:

```bash
terraform output ip_address
terraform output public_domain
```

Or check via gcloud:

```bash
gcloud compute instances list
```

## 🔐 Accessing EJBCA

### Access via Web Browser

Once deployment completes, access EJBCA:

1. **Get the public IP:**
```bash
terraform output ip_address
```

2. **Access via browser:**
```
https://<IP_ADDRESS>.nip.io
```

Or use the auto-generated domain:
```
https://<IP_ADDRESS>.nip.io
```

### Default Credentials

⚠️ **Security Warning:** Change these immediately!

- **Username:** `admin`
- **Password:** `admin`

### SSH Access

SSH into the VM:

```bash
gcloud compute ssh ca-vm-ejbca --zone=us-central1-a
```

Or using the IP directly:

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@$(terraform output -raw ip_address)
```

## 🔍 Verification

### Check Container Status

SSH into the VM and check containers:

```bash
sudo docker compose ps
```

### View Logs

```bash
sudo docker compose logs ejbca
sudo docker compose logs caddy
```

### Test Connectivity

From your local machine:

```bash
curl -vk https://$(terraform output -raw ip_address).nip.io
```

### Health Check

```bash
curl -k https://$(terraform output -raw ip_address).nip.io/ejbca/publicweb/healthcheck/ejbcahealth
```

## 🖥️ Alternative: Manual VM Creation

If you prefer not to use Terraform, create a VM manually:

```bash
gcloud compute instances create ejbca-vm \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --boot-disk-size=30GB \
  --tags=http-server,https-server
```

**SSH connection:**

```bash
gcloud compute ssh ejbca-vm --zone us-central1-a
```

Then follow the manual installation guide or container deployment guide.

## 🔄 Container Management

### View Container Status

```bash
sudo docker compose ps
```

### View Logs

```bash
sudo docker compose logs -f ejbca
sudo docker compose logs -f caddy
```

### Restart Services

```bash
sudo docker compose restart
```

### Update Configuration

1. SSH into the VM
2. Edit configuration files in `/opt/ejbca`
3. Restart services:
```bash
sudo docker compose restart
```

## 🚀 Lightweight Alternative: Smallstep CA

If EJBCA doesn't fit in your VM resources, you can deploy Smallstep CA instead.

### Configure for Smallstep

Edit `terraform.tfvars`:

```hcl
ca_type = "step"
```

Then redeploy:

```bash
terraform apply -auto-approve
```

### Manual Smallstep Installation

If deploying manually:

```bash
curl -fssl https://smallstep.com/install | sh
sudo mv ~/.step/bin/step /usr/local/bin/
```

**Initialize:**

```bash
step ca init
```

Answer the prompts:
- Name: `Smallstep CA`
- DNS or IP: `localhost` or your public IP
- Provisioner: `admin@example.com`
- Save password: `no` (or `yes` if you want)

**Start the CA:**

```bash
step ca start
```

**With web UI:**

```bash
step ca start --ui
```

### Smallstep Usage

**Check health:**

```bash
step ca health
```

**Issue a certificate:**

```bash
step ca certificate example.com example.crt example.key
```

**Access web UI:**

```
http://<VM_IP>:9000/ui
```

## 🧹 Cleanup and Cost Management

### Stop the VM (Pause Costs)

Stop the VM to pause most costs (static IP still charges):

```bash
gcloud compute instances stop ca-vm-ejbca --zone=us-central1-a
```

### Destroy Infrastructure (Terraform)

Destroy all resources created by Terraform:

```bash
terraform destroy
```

Type `yes` when prompted, or use:

```bash
terraform destroy -auto-approve
```

### Manual Cleanup

If not using Terraform:

1. **Delete VM:**
```bash
gcloud compute instances delete ejbca-vm --zone=us-central1-a --quiet
```

2. **Delete disk:**
```bash
gcloud compute disks delete ejbca-vm --zone=us-central1-a --quiet
```

3. **Delete static IP (if created):**
```bash
gcloud compute addresses delete ca-ip --region=us-central1 --quiet
```

4. **Delete firewall rules:**
```bash
gcloud compute firewall-rules delete allow-ca --quiet
```

### Verify Cleanup

Ensure nothing remains:

```bash
gcloud compute instances list
gcloud compute disks list
gcloud compute addresses list
gcloud compute firewall-rules list
```

### Delete Project (Optional)

⚠️ **Warning:** This permanently deletes the project!

```bash
gcloud projects delete my-pki-lab
```

## 💰 Cost Management

### Free Tier Resources

Google Cloud Free Tier includes:
- **e2-micro VM:** 1 per month (limited hours)
- **30GB standard persistent disk:** Free up to 30GB
- **Network egress:** 1GB per month free

### Estimated Costs

- **e2-micro VM (running 24/7):** ~$7-10/month
- **e2-medium VM (running 24/7):** ~$25-30/month
- **Static IP (not attached):** ~$0.01/hour
- **Network egress:** ~$0.12/GB (after free tier)

### Cost Optimization Tips

1. **Stop VMs when not in use** (saves compute costs)
2. **Use preemptible instances** for testing (up to 80% discount)
3. **Delete unused static IPs**
4. **Monitor usage** in Google Cloud Console
5. **Set billing alerts** to avoid surprises

## 🔐 Security Considerations

### Firewall Rules

The Terraform configuration creates firewall rules allowing:
- SSH (port 22)
- HTTP (port 80)
- HTTPS (port 443)
- EJBCA ports (8080, 8443)
- Smallstep CA (port 9000)

**For production:**
- Restrict source IPs instead of `0.0.0.0/0`
- Use VPN or Cloud IAP for SSH access
- Implement proper network segmentation

### Default Passwords

⚠️ **Change all default passwords immediately:**

- Database passwords
- EJBCA admin credentials
- SSH keys should be properly secured

### SSL/TLS Certificates

The Caddy reverse proxy automatically obtains Let's Encrypt certificates. For production:
- Use proper domain names
- Configure certificate renewal monitoring
- Consider using Google-managed certificates

## 🐛 Troubleshooting

### VM Won't Start

1. **Check quotas:**
```bash
gcloud compute project-info describe
```

2. **Check billing:**
```bash
gcloud billing accounts list
```

3. **Check logs:**
```bash
gcloud compute instances get-serial-port-output ca-vm-ejbca --zone=us-central1-a
```

### Containers Not Starting

1. **SSH into VM:**
```bash
gcloud compute ssh ca-vm-ejbca --zone=us-central1-a
```

2. **Check Docker:**
```bash
sudo systemctl status docker
sudo docker ps -a
```

3. **Check logs:**
```bash
sudo journalctl -u docker
sudo docker compose logs
```

### Can't Access Web Interface

1. **Check firewall rules:**
```bash
gcloud compute firewall-rules list
```

2. **Check VM tags:**
```bash
gcloud compute instances describe ca-vm-ejbca --zone=us-central1-a
```

3. **Test from VM itself:**
```bash
curl -k https://localhost:8443/ejbca/publicweb/healthcheck/ejbcahealth
```

### Terraform Errors

1. **Check authentication:**
```bash
gcloud auth list
```

2. **Verify project:**
```bash
gcloud config get-value project
```

3. **Check Terraform state:**
```bash
terraform show
```

4. **Refresh state:**
```bash
terraform refresh
```

## 📚 Additional Resources

- [EJBCA Documentation](https://doc.primekey.com/ejbca)
- [EJBCA Community Edition GitHub](https://github.com/Keyfactor/ejbca-ce)
- [Smallstep CA Documentation](https://smallstep.com/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- [Google Cloud Free Tier](https://cloud.google.com/free)
- [Caddy Documentation](https://caddyserver.com/docs/)

## 📝 Notes

- 💰 **Cost:** This lab uses Google Cloud resources that may incur charges
- 🔒 **Security:** Change all default passwords immediately
- 💾 **Backup:** Consider backing up EJBCA data before cleanup
- 📊 **Monitoring:** Check Google Cloud Console for unexpected charges
- 🎓 **Learning:** This setup is ideal for learning and testing

---

**Happy cloud PKI building! ☁️🔐**

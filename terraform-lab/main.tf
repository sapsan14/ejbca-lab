terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

# Резервируем статический IP
resource "google_compute_address" "ca_ip" {
  name   = "ca-ip"
  region = var.region
}

# Firewall для SSH, HTTP, HTTPS, EJBCA/Step CA
resource "google_compute_firewall" "allow_ca" {
  name    = "allow-ca"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080", "8443", "9000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ca-server"]
}

# VM для CA
resource "google_compute_instance" "ca_vm" {
  name         = "ca-vm-${var.ca_type}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["ca-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.ca_ip.address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt update
    apt install -y curl unzip docker.io

    if [ "${var.ca_type}" = "ejbca" ]; then
      echo "Installing EJBCA..."
      docker run -d -p 8443:8443 -p 8080:8080 keyfactor/ejbca-ce
    else
      echo "Installing Step CA..."
      curl -fSSL https://smallstep.com/certificates/install | bash
      step ca init --name "GCP Step CA" --dns "$(curl -s ifconfig.me)" --address ":9000" --provisioner "admin@example.com" --acme
      nohup step-ca $(step path)/config/ca.json > /var/log/step-ca.log 2>&1 &
    fi
  EOT
}

# Выводим статический IP и домен
output "ip_address" {
  description = "Static IP address"
  value       = google_compute_address.ca_ip.address
}

output "public_domain" {
  description = "Auto domain via nip.io (use this in browser)"
  value       = "${google_compute_address.ca_ip.address}.nip.io"
}

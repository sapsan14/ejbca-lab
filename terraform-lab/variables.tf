variable "project" {
  description = "GCP project id"
  type        = string
}

variable "ca_type" {
  description = "Choose which CA to install: ejbca or step"
  type        = string
  default     = "ejbca"
}

variable "region" {
  description = "GCP region (use one of regions supported by free tier)"
  type        = string
  default     = "europe-north1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "europe-north1-b"
}

variable "machine_type" {
  description = "Machine type (e2-micro fits free tier)"
  type        = string
  default     = "e2-micro" # "e2-medium"
}

variable "ssh_key" {
  description = "SSH public key for 'ubuntu' user (format: 'ssh-rsa AAAA... user@host')"
  type        = string
}

variable "admin_email" {
  description = "Email for Let's Encrypt notifications"
  type        = string
  default     = "sokolovmeister@gmail.com"
}

terraform {
  required_version = ">= 0.15"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.90.0"
    }
  }
}



provider "proxmox" {

  endpoint = var.proxmox_endpoint
  # api_token = "api_token"
  # TODO: use terraform variable or remove the line, and use PROXMOX_VE_USERNAME environment variable
  username = var.proxmox_username
  # TODO: use terraform variable or remove the line, and use PROXMOX_VE_PASSWORD environment variable
  password = var.proxmox_password

  # because self-signed TLS certificate is in use
  insecure = true
  # uncomment (unless on Windows...)
  # tmp_dir  = "/var/tmp"

  ssh {
    agent = false
    # TODO: uncomment and configure if using api_token instead of password
    username = "root"
    password = "Natnat888"
  }
}


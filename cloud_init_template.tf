# Download Debian Cloud Image
resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "iso"
  datastore_id = "nfs-backups"
  file_name    = "debian-13-genericcloud-amd64.img"
  node_name    = "pve3"
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

# SSH Key for cloud-init template
resource "tls_private_key" "cloud_init_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Debian Cloud-Init Template
resource "proxmox_virtual_environment_vm" "debian_cloud_template" {
  name        = "debian-cloud-template"
  description = "Debian Cloud-Init Template - Managed by Terraform"
  tags        = ["terraform", "debian", "cloud-init", "template"]

  node_name = "pve3"
  vm_id     = 9000 # Standard template ID range
  template  = true

  agent {
    enabled = true
    timeout = "15m"
    type    = "virtio"
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
    # No MAC address - will be auto-generated for each clone
  }

  operating_system {
    type = "l26"
  }

  serial_device {
    device = "socket"
  }

  scsi_hardware = "virtio-scsi-single"

  # Cloud image disk
  disk {
    datastore_id = "nfs-backups"
    file_id      = proxmox_virtual_environment_download_file.debian_cloud_image.id
    interface    = "scsi0"
    size         = 20
  }

  # Cloud-init drive
  # disk {
  #   datastore_id = "local"
  #   file_format  = "raw"
  #   interface    = "ide2"
  #   size         = 4
  # }

  # Cloud-init configuration
  initialization {
    datastore_id = "nfs-backups"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.cloud_init_key.public_key_openssh)]
      password = var.instance_password
      username = var.instance_username
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init_user_data.id
  }

  lifecycle {
    # prevent_destroy = true
    ignore_changes = [
      # Ignore changes that might occur during template updates
      disk[0].file_id,
      initialization[0].user_data_file_id
    ]
  }
}

# Cloud-init user data configuration
resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
  content_type = "snippets"
  datastore_id = "nfs-backups"
  node_name    = "pve3"

  source_raw {
    data = templatefile("${path.module}/cloud-init/cloud-init-user-data.yml", {
      username       = var.instance_username
      password       = var.instance_password
      ssh_key        = trimspace(tls_private_key.cloud_init_key.public_key_openssh)
      vm_hostname    = "debian-cloud-template"
      custom_packages = []
    })
    file_name = "cloud-init-user-data.yml"
  }
}


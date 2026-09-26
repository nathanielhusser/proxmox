# Debian Cloud-Init VM Module
# Creates a VM by cloning from an existing Debian cloud-init template

# Conditionally create SSH key pair for this VM
resource "tls_private_key" "vm_key" {
  count     = var.create_ssh_key ? 1 : 0
  algorithm = "ED25519"
}

locals {
  # Combine default tags with user-provided tags
  all_tags = concat(["terraform", "debian", "vm"], var.tags)

  # Use created key or provided key
  ssh_public_key = var.create_ssh_key ? tls_private_key.vm_key[0].public_key_openssh : var.ssh_public_key
}

# Cloud-init user data for this specific VM
resource "proxmox_virtual_environment_file" "user_data" {
  content_type = "snippets"
  datastore_id = var.datastore
  node_name    = var.node

  source_raw {
    data = templatefile("${path.module}/templates/cloud-init-user-data.yml", {
      username        = var.instance_username
      password        = var.instance_password
      ssh_key         = trimspace(local.ssh_public_key)
      vm_hostname     = var.machine_name
      custom_packages = var.custom_packages
      custom_runcmd   = var.custom_runcmd
    })
    file_name = "${var.machine_name}-user-data.yml"
  }
}

# Main VM resource - cloned from template
resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.machine_name
  description = var.description
  tags        = local.all_tags

  node_name     = var.node
  vm_id         = var.vm_id
  scsi_hardware = "virtio-scsi-single"

  agent {
    enabled = var.agent_enabled
    timeout = var.agent_timeout
    type    = "virtio"
  }

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  started         = var.started
  on_boot         = var.on_boot
  stop_on_destroy = true

  cpu {
    cores   = var.cpu_cores
    sockets = var.cpu_sockets
    type    = var.cpu_type
  }

  memory {
    dedicated = var.memory
  }

  network_device {
    bridge   = var.network_bridge
    model    = "virtio"
    firewall = var.firewall_enabled
  }

  operating_system {
    type = "l26"
  }

  serial_device {
    device = "socket"
  }

  disk {
    datastore_id = var.datastore
    interface    = "scsi0"
    size         = var.disk_size
  }

  initialization {
    datastore_id      = var.datastore
    user_data_file_id = proxmox_virtual_environment_file.user_data.id

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_address != "dhcp" ? var.ipv4_gateway : null
      }
    }

    user_account {
      keys     = [trimspace(local.ssh_public_key)]
      password = var.instance_password
      username = var.instance_username
    }
  }

  lifecycle {
    ignore_changes = [
      cdrom,
      network_device[0].mac_address,
    ]
  }
}

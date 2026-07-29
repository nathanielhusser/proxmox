# Example: Deploy VMs from Debian Cloud-Init Template
# This shows how to create VMs from the cloud-init template

# Example VM 1: Web Server
resource "proxmox_virtual_environment_vm" "web_server" {
  name        = "web-server-${random_id.vm_id_1.hex}"
  description = "Web Server from Cloud-Init Template - Managed by Terraform"
  tags        = ["terraform", "debian", "web-server", "production"]

  node_name = "pve2"
  vm_id     = 301 # Choose available VM ID

  # Clone from template
  clone {
    vm_id = proxmox_virtual_environment_vm.debian_cloud_template.vm_id
    full  = true
  }

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
    dedicated = 4096
  }

  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
    # MAC address will be auto-generated to prevent conflicts
  }

  operating_system {
    type = "l26"
  }

  serial_device {
    device = "socket"
  }

  # Resize disk if needed
  disk {
    datastore_id = "local"
    interface    = "scsi0"
    size         = 40 # Increase from template's 20GB
  }

  # Cloud-init configuration for this specific VM
  initialization {
    datastore_id = "local"

    ip_config {
      ipv4 {
        address = "dhcp" # Uses DHCP to prevent IP conflicts
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.cloud_init_key.public_key_openssh)]
      password = var.instance_password
      username = var.instance_username
    }

    # Custom user data for this VM
    user_data_file_id = proxmox_virtual_environment_file.web_server_user_data.id
  }

  # Start after creation
  started = true

  lifecycle {
    ignore_changes = [
      # Ignore network changes after deployment
      network_device[0].mac_address,
    ]
  }
}

# Custom cloud-init for web server
resource "proxmox_virtual_environment_file" "web_server_user_data" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve2"

  source_raw {
    data = templatefile("${path.module}/cloud-init/web-server-user-data.yml", {
      username = var.instance_username
      ssh_key  = trimspace(tls_private_key.cloud_init_key.public_key_openssh)
      vm_name  = "web-server-${random_id.vm_id_1.hex}"
    })
    file_name = "web-server-user-data-${random_id.vm_id_1.hex}.yml"
  }
}

# Example VM 2: Database Server
resource "proxmox_virtual_environment_vm" "database_server" {
  name        = "db-server-${random_id.vm_id_2.hex}"
  description = "Database Server from Cloud-Init Template - Managed by Terraform"
  tags        = ["terraform", "debian", "database", "production"]

  node_name = "pve3"
  vm_id     = 302

  clone {
    vm_id = proxmox_virtual_environment_vm.debian_cloud_template.vm_id
    full  = true
  }

  agent {
    enabled = true
    timeout = "15m"
    type    = "virtio"
  }

  cpu {
    cores   = 4
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 8192
  }

  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
  }

  operating_system {
    type = "l26"
  }

  serial_device {
    device = "socket"
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    size         = 80
  }

  initialization {
    datastore_id = "local"

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

    user_data_file_id = proxmox_virtual_environment_file.db_server_user_data.id
  }

  started = true

  lifecycle {
    ignore_changes = [
      network_device[0].mac_address,
    ]
  }
}

resource "proxmox_virtual_environment_file" "db_server_user_data" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve3"

  source_raw {
    data = templatefile("${path.module}/cloud-init/db-server-user-data.yml", {
      username = var.instance_username
      ssh_key  = trimspace(tls_private_key.cloud_init_key.public_key_openssh)
      vm_name  = "db-server-${random_id.vm_id_2.hex}"
    })
    file_name = "db-server-user-data-${random_id.vm_id_2.hex}.yml"
  }
}

# Random IDs for unique VM names and avoid conflicts
resource "random_id" "vm_id_1" {
  byte_length = 4
}

resource "random_id" "vm_id_2" {
  byte_length = 4
}
resource "proxmox_virtual_environment_vm" "debian_gitea" {
  name        = "Debian-Gitea"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian", "git", "vm"]

  node_name     = "pve2"
  vm_id         = 102
  scsi_hardware = "virtio-scsi-single"
  agent {
    enabled = true
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
    bridge      = "vmbr0"
    mac_address = "46:FB:F2:BC:20:14"
    model       = "virtio"
    firewall    = true
  }

  operating_system {
    type = "l26"
  }

  serial_device {
    device = "socket"
  }
}

resource "proxmox_virtual_environment_vm" "torrent_debian" {
  name        = "Debian-Torrent"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian", "torrent", "vm"]

  node_name     = "pve3"
  vm_id         = 210
  scsi_hardware = "virtio-scsi-single"
  agent {
    enabled = false
    type    = "virtio"
  }

  stop_on_destroy = true

  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = "46:FB:F2:BC:20:14"
    model       = "virtio"
    firewall    = true
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
    size         = 64
  }
  cdrom {
    file_id = proxmox_virtual_environment_download_file.debian_13.id
    enabled = false
  }
  lifecycle {
    ignore_changes = [cdrom]
  }
}

resource "proxmox_virtual_environment_vm" "truenas_nas" {
  name        = "TreuNAS-NAS"
  description = "Managed by Terraform"
  tags        = ["terraform", "truenas", "nas", "vm"]

  node_name = "pve4"
  vm_id     = 200

  lifecycle {
    ignore_changes = [
      disk # Ignores all changes to all disk blocks
    ]
  }

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }
  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES" # recommended for modern CPUs
  }

  memory {
    dedicated = 8192
    floating  = 8192 # set equal to dedicated to enable ballooning
  }

  # cdrom {
  #   file_id      = proxmox_virtual_environment_download_file.truenas_scale.id
  # }

  disk {
    file_format  = "qcow2"
    interface    = "scsi0"
    datastore_id = "local"
    size         = 32
  }
  initialization {
    datastore_id = "local"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.truenas_vm_key.public_key_openssh)]
      password = var.instance_password
      username = var.instance_username
    }

  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

}

resource "tls_private_key" "truenas_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Missing VMs to import
resource "proxmox_virtual_environment_vm" "debian_template" {
  name        = "Debian"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian", "template", "vm"]
  node_name   = "pve"
  vm_id       = 105
  template    = true

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      initialization,
      ipv4_addresses,
      ipv6_addresses,
      mac_addresses,
      network_interface_names,
      agent,
      scsi_hardware,
      serial_device
    ]
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024
  }

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_vm" "debian_ansible" {
  name        = "Debian-Ansible"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian", "ansible", "vm"]
  node_name   = "pve2"
  vm_id       = 103

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      initialization,
      ipv4_addresses,
      ipv6_addresses,
      mac_addresses,
      network_interface_names,
      agent,
      scsi_hardware,
      serial_device
    ]
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024
  }

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_vm" "debian_backup" {
  name        = "Debian-Backup"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian", "backup", "vm"]
  node_name   = "pve2"
  vm_id       = 112

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      initialization,
      ipv4_addresses,
      ipv6_addresses,
      mac_addresses,
      network_interface_names,
      agent,
      scsi_hardware,
      serial_device,
      hostpci
    ]
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 4096
  }

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_vm" "debian_wireguard" {
  name        = "Debian-Wireguard"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian", "vpn", "wireguard", "vm"]
  node_name   = "pve2"
  vm_id       = 110

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      initialization,
      ipv4_addresses,
      ipv6_addresses,
      mac_addresses,
      network_interface_names,
      agent,
      scsi_hardware,
      serial_device
    ]
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024
  }

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_vm" "windows_server_dns" {
  name        = "Windows-Server-DNS"
  description = "Managed by Terraform"
  tags        = ["terraform", "windows", "dns", "server", "vm"]
  node_name   = "pve2"
  vm_id       = 109

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      initialization,
      ipv4_addresses,
      ipv6_addresses,
      mac_addresses,
      network_interface_names,
      agent,
      scsi_hardware,
      serial_device,
      machine
    ]
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  operating_system {
    type = "win10"
  }
}

resource "proxmox_virtual_environment_vm" "kali_security" {
  name        = "Kali-Security"
  description = "Managed by Terraform"
  tags        = ["terraform", "kali", "security", "linux", "vm"]
  node_name   = "pve2"
  vm_id       = 116

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      initialization,
      ipv4_addresses,
      ipv6_addresses,
      mac_addresses,
      network_interface_names,
      agent,
      scsi_hardware,
      serial_device
    ]
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_vm" "debian_file" {
  name        = "Debian-File"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian", "file-server", "vm"]
  node_name   = "pve3"
  vm_id       = 117

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      initialization,
      ipv4_addresses,
      ipv6_addresses,
      mac_addresses,
      network_interface_names,
      agent,
      scsi_hardware,
      serial_device
    ]
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_vm" "elive_syncthing" {
  name        = "Elive-Syncthing"
  description = "Managed by Terraform"
  tags        = ["terraform", "elive", "syncthing", "sync", "vm"]
  node_name   = "pve3"
  vm_id       = 114

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      initialization,
      ipv4_addresses,
      ipv6_addresses,
      mac_addresses,
      network_interface_names,
      agent,
      scsi_hardware,
      serial_device
    ]
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }


  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_vm" "debian_code" {
  name        = "Debian-Code"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian", "development", "code", "vm"]
  node_name   = "pve3"
  vm_id       = 106

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      initialization,
      ipv4_addresses,
      ipv6_addresses,
      mac_addresses,
      network_interface_names,
      agent,
      scsi_hardware,
      serial_device
    ]
  }

  cpu {
    cores = 4
  }

  memory {
    dedicated = 4096
  }

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_vm" "photos_debian" {
  name        = "Debian-Photos"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian", "photos", "vm"]

  node_name     = "pve3"
  vm_id         = 311
  scsi_hardware = "virtio-scsi-single"
  agent {
    enabled = true
    type    = "virtio"
  }

  clone {
    vm_id = proxmox_virtual_environment_vm.debian_cloud_template.id
    full  = true
  }

  stop_on_destroy = true

  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
    # mac_address = "46:FB:F2:BC:20:14"
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
    datastore_id = "nfs-backups"
    interface    = "scsi0"
    size         = 64
  }
  initialization {
    datastore_id      = "nfs-backups"
    user_data_file_id = proxmox_virtual_environment_file.photos_user_data.id

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
  }
  # cdrom {
  #   file_id = proxmox_virtual_environment_download_file.debian_13.id
  #   enabled = true
  # }
  lifecycle {
    ignore_changes = [cdrom]
  }
}

# Custom cloud-init for photos VM with correct hostname
resource "proxmox_virtual_environment_file" "photos_user_data" {
  content_type = "snippets"
  datastore_id = "nfs-backups"
  node_name    = "pve3"

  source_raw {
    data = templatefile("${path.module}/cloud-init/cloud-init-user-data.yml", {
      username        = var.instance_username
      password        = var.instance_password
      ssh_key         = trimspace(tls_private_key.cloud_init_key.public_key_openssh)
      vm_hostname     = "Debian-Photos"
      custom_packages = []
    })
    file_name = "photos-user-data.yml"
  }
}


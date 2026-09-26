resource "proxmox_virtual_environment_container" "monitoring_container" {
  description = "Monitoring services container"
  tags        = ["terraform", "debian", "monitoring", "lxc"]

  node_name = "pve"
  vm_id     = 204

  initialization {
    hostname = "monitor-container"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.monitor_container_key.public_key_openssh)
      ]
      password = var.instance_password
    }
  }

  network_interface {
    name = "veth0"
  }

  disk {
    datastore_id = "local"
    size         = 8
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
    type = "debian"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
}

resource "tls_private_key" "monitor_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Game Manager Container
resource "proxmox_virtual_environment_container" "gamemanager_container" {
  description = "Game managing container"
  tags        = ["terraform", "debian", "gaming", "lxc"]

  node_name = "pve"
  vm_id     = 206

  initialization {
    hostname = "gamemanager-container"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.gamemanager_container_key.public_key_openssh)
      ]
      password = var.instance_password
    }
  }

  network_interface {
    name = "veth0"
  }

  disk {
    datastore_id = "local"
    size         = 32
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
    type = "debian"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
}

resource "tls_private_key" "gamemanager_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

## AI Container
resource "proxmox_virtual_environment_container" "ai_container" {
  description = "AI container"
  tags        = ["terraform", "debian", "ai", "machine-learning", "lxc"]

  node_name = "pve"
  vm_id     = 208

  initialization {
    hostname = "ai-container"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.ai_container_key.public_key_openssh)
      ]
      password = var.instance_password
    }
  }

  network_interface {
    name = "veth0"
  }

  disk {
    datastore_id = "local"
    size         = 32
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
    type = "debian"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  memory {
    dedicated = 2048
    swap      = 0
  }
}

resource "tls_private_key" "ai_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# PostgreSQL Container
resource "proxmox_virtual_environment_container" "postgres_container" {
  description = "PostgreSQL database container"
  tags        = ["terraform", "debian", "database", "postgresql", "lxc"]

  node_name = "pve"
  vm_id     = 209

  initialization {
    hostname = "postgres-container"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.postgres_container_key.public_key_openssh)
      ]
      password = var.instance_password
    }
  }

  network_interface {
    name = "veth0"
  }

  disk {
    datastore_id = "local"
    size         = 16
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type             = "debian"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  memory {
    dedicated = 2048
    swap      = 512
  }

  cpu {
    cores = 2
  }
}

resource "tls_private_key" "postgres_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Missing LXC containers to import
resource "proxmox_virtual_environment_container" "debian_container_104" {
  description = "Debian Container 104"
  tags        = ["terraform", "debian", "lxc"]
  node_name   = "pve"
  vm_id       = 104

  lifecycle {
    ignore_changes = [
      initialization[0].user_account,
      operating_system[0].template_file_id,
      unprivileged,
      console,
      network_interface[0].mac_address,
      initialization[0].hostname
    ]
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_interface {
    name = "eth0"
  }

  disk {
    datastore_id = "local"
    size         = 8
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type             = "debian"
  }

  memory {
    dedicated = 512
    swap      = 512
  }
}


resource "proxmox_virtual_environment_container" "debian_container_template" {
  description = "Debian Container Template"
  tags        = ["terraform", "debian", "template", "lxc"]
  node_name   = "pve"
  vm_id       = 107
  template    = true

  lifecycle {
    ignore_changes = [
      initialization[0].user_account,
      operating_system[0].template_file_id,
      unprivileged,
      console,
      network_interface[0].mac_address,
      initialization[0].hostname
    ]
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_interface {
    name = "eth0"
  }

  disk {
    datastore_id = "local"
    size         = 8
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type             = "debian"
  }

  memory {
    dedicated = 512
    swap      = 512
  }
}


resource "proxmox_virtual_environment_container" "project_container" {
  description = "Project Container"
  tags        = ["terraform", "debian", "development", "lxc"]
  node_name   = "pve"
  vm_id       = 115
  started     = false

  lifecycle {
    ignore_changes = [
      initialization[0].user_account,
      operating_system[0].template_file_id,
      unprivileged,
      console,
      network_interface[0].mac_address,
      initialization[0].hostname
    ]
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }

  network_interface {
    name     = "eth0"
    firewall = true
  }

  disk {
    datastore_id = "local"
    size         = 8
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type             = "debian"
  }

  memory {
    dedicated = 512
    swap      = 512
  }
}


resource "proxmox_virtual_environment_container" "wiki_container" {
  description = "Wiki Container"
  tags        = ["terraform", "debian", "wiki", "documentation", "lxc"]
  node_name   = "pve"
  vm_id       = 113

  lifecycle {
    ignore_changes = [
      initialization[0].user_account,
      operating_system[0].template_file_id,
      unprivileged,
      console,
      network_interface[0].mac_address,
      initialization[0].hostname
    ]
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }

  network_interface {
    name     = "eth0"
    firewall = true
  }

  disk {
    datastore_id = "local"
    size         = 8
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type             = "debian"
  }

  memory {
    dedicated = 512
    swap      = 512
  }
}


resource "proxmox_virtual_environment_container" "bh_container" {
  description = "BH Container"
  tags        = ["terraform", "debian", "lxc"]
  node_name   = "pve"
  vm_id       = 111

  lifecycle {
    ignore_changes = [
      initialization[0].user_account,
      operating_system[0].template_file_id,
      unprivileged,
      console,
      network_interface[0].mac_address,
      initialization[0].hostname
    ]
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_interface {
    name     = "eth0"
    firewall = true
  }

  disk {
    datastore_id = "local"
    size         = 8
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type             = "debian"
  }

  memory {
    dedicated = 512
    swap      = 512
  }
}


resource "proxmox_virtual_environment_container" "dev_db" {
  description = "Development Database Container"
  tags        = ["terraform", "debian", "database", "development", "lxc"]
  node_name   = "pve"
  vm_id       = 108

  lifecycle {
    ignore_changes = [
      initialization[0].user_account,
      operating_system[0].template_file_id,
      unprivileged,
      console,
      network_interface[0].mac_address,
      initialization[0].hostname
    ]
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_interface {
    name = "eth0"
  }

  disk {
    datastore_id = "local"
    size         = 8
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type             = "debian"
  }

  memory {
    dedicated = 512
    swap      = 512
  }
}


resource "proxmox_virtual_environment_container" "log_container" {
  description = "Log Container"
  tags        = ["terraform", "debian", "logging", "lxc"]
  node_name   = "pve"
  vm_id       = 100

  lifecycle {
    ignore_changes = [
      initialization[0].user_account,
      operating_system[0].template_file_id,
      unprivileged,
      console,
      network_interface[0].mac_address,
      initialization[0].hostname
    ]
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }

  network_interface {
    name     = "eth0"
    firewall = true
  }

  disk {
    datastore_id = "local"
    size         = 40
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type             = "debian"
  }

  memory {
    dedicated = 512
    swap      = 512
  }
}


resource "proxmox_virtual_environment_container" "proxy_container" {
  description = "Proxy Container"
  tags        = ["terraform", "debian", "proxy", "networking", "lxc"]
  node_name   = "pve"
  vm_id       = 101

  lifecycle {
    ignore_changes = [
      initialization[0].user_account,
      operating_system[0].template_file_id,
      unprivileged,
      console,
      network_interface[0].mac_address,
      initialization[0].hostname
    ]
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }

  network_interface {
    name = "eth0"
  }

  disk {
    datastore_id = "local"
    size         = 8
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type             = "debian"
  }

  memory {
    dedicated = 512
    swap      = 512
  }
}


resource "proxmox_virtual_environment_container" "file_container" {
  description = "File Container"
  tags        = ["terraform", "debian", "file-server", "lxc"]
  node_name   = "pve4"
  vm_id       = 203
  started     = false

  lifecycle {
    ignore_changes = [
      initialization[0].user_account,
      operating_system[0].template_file_id,
      unprivileged,
      console,
      network_interface[0].mac_address,
      initialization[0].hostname
    ]
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }

  network_interface {
    name     = "eth0"
    firewall = true
  }

  disk {
    datastore_id = "local"
    size         = 8
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type             = "debian"
  }

  memory {
    dedicated = 1024
    swap      = 1024
  }
}


resource "proxmox_virtual_environment_container" "jellyfin_media" {
  node_name = "pve4"
  vm_id     = 202
  tags      = ["terraform", "debian", "media", "jellyfin", "proxmox-helper-scripts", "lxc"]

  lifecycle {
    ignore_changes = [
      description,
      initialization[0].user_account,
      operating_system[0].template_file_id,
      unprivileged,
      console,
      network_interface[0].mac_address,
      initialization[0].hostname
    ]
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_interface {
    name = "eth0"
  }

  disk {
    datastore_id = "local"
    size         = 8
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type             = "debian"
  }

  memory {
    dedicated = 2048
    swap      = 512
  }

  cpu {
    cores = 2
  }
}


module "splunk_server" {
  source            = "./modules/debian-cloud-init"
  machine_name      = "Debian-Splunk"
  vm_id             = 312
  instance_username = var.instance_username
  instance_password = var.instance_password
  ssh_public_key    = trimspace(tls_private_key.cloud_init_key.public_key_openssh)

  # Optional - Infrastructure
  node           = "pve3"
  datastore      = "nfs-backups"
  template_vm_id = 9000

  # Optional - Resources
  cpu_cores   = 2
  cpu_sockets = 1
  memory      = 8192
  disk_size   = 64

  # Optional - Network
  network_bridge   = "vmbr0"
  firewall_enabled = true
  ipv4_address     = "dhcp"

  # Optional - VM behavior
  started = true
  on_boot = true
  tags    = ["production", "web"]

  # Optional - Cloud-init customization
  custom_packages = ["neovim", "neofetch", "wget"]
  custom_runcmd = [

  ]
}

output "vm_id" {
  description = "The VM ID"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "vm_name" {
  description = "The VM name"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "node_name" {
  description = "The Proxmox node where the VM is running"
  value       = proxmox_virtual_environment_vm.vm.node_name
}

output "ipv4_addresses" {
  description = "The IPv4 addresses of the VM"
  value       = proxmox_virtual_environment_vm.vm.ipv4_addresses
}

output "mac_addresses" {
  description = "The MAC addresses of the VM"
  value       = proxmox_virtual_environment_vm.vm.mac_addresses
}

output "tags" {
  description = "The tags assigned to the VM"
  value       = proxmox_virtual_environment_vm.vm.tags
}

output "ssh_private_key" {
  description = "The generated SSH private key (only if create_ssh_key = true)"
  value       = var.create_ssh_key ? tls_private_key.vm_key[0].private_key_openssh : null
  sensitive   = true
}

output "ssh_public_key" {
  description = "The SSH public key used for this VM"
  value       = local.ssh_public_key
}

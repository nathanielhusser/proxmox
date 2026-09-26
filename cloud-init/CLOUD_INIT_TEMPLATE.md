# Debian Cloud-Init Template for Proxmox

This configuration creates a Debian cloud-init template that prevents split brain issues and IP conflicts in your Proxmox environment.

## Features

- **Split Brain Prevention**: Each VM gets a unique machine ID and SSH host keys
- **IP Conflict Prevention**: DHCP with MAC-based client identification
- **Security Hardening**: Firewall, fail2ban, and SSH key authentication
- **Template Ready**: Optimized for cloning with cloud-init support
- **Unique Identity**: Automatic hostname generation based on machine ID

## Files Created

1. `cloud_init_template.tf` - Main template configuration
2. `cloud-init-user-data.yml` - Base cloud-init configuration
3. `example_vm_from_template.tf` - Example VMs using the template
4. `web-server-user-data.yml` - Web server specific configuration
5. `db-server-user-data.yml` - Database server specific configuration

## Prerequisites

1. Proxmox VE cluster with Terraform provider configured
2. Variables defined in `terraform.tfvars`:
   ```hcl
   instance_username = "your-username"
   instance_password = "your-secure-password"
   ```

## Deployment Steps

### 1. Create the Template

```bash
# Apply only the template configuration first
terraform apply -target=proxmox_virtual_environment_vm.debian_cloud_template
```

### 2. Deploy VMs from Template

```bash
# Deploy example VMs (optional)
terraform apply -target=proxmox_virtual_environment_vm.web_server
terraform apply -target=proxmox_virtual_environment_vm.database_server

# Or deploy all remaining resources
terraform apply
```

## Template Features

### Split Brain Prevention

- **Unique Machine ID**: Generated on each boot/clone
- **SSH Host Keys**: Regenerated for each VM instance
- **Hostname**: Auto-generated based on machine ID
- **DHCP Client ID**: Based on MAC address

### Network Configuration

- **DHCP**: Automatic IP assignment prevents static IP conflicts
- **MAC-based Client ID**: Ensures unique DHCP reservations
- **Network Restart**: Automatic network service restart on conflicts

### Security Features

- **Firewall (UFW)**: Enabled by default
- **Fail2ban**: SSH brute force protection
- **SSH Key Authentication**: Password authentication available as backup
- **Package Updates**: Automatic security updates on first boot

## Creating Custom VMs

To create a new VM from the template:

```hcl
resource "proxmox_virtual_environment_vm" "my_custom_vm" {
  name        = "my-vm-${random_id.my_vm.hex}"
  description = "Custom VM from Cloud-Init Template"
  tags        = ["terraform", "debian", "custom"]

  node_name = "pve2"  # Choose your node
  vm_id     = 350     # Choose available ID

  # Clone from template
  clone {
    vm_id = proxmox_virtual_environment_vm.debian_cloud_template.vm_id
    full  = true
  }

  # Configure resources
  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  # Network with auto-generated MAC
  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
  }

  # Cloud-init configuration
  initialization {
    datastore_id = "local"

    ip_config {
      ipv4 {
        address = "dhcp"  # Prevents IP conflicts
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.cloud_init_key.public_key_openssh)]
      password = var.instance_password
      username = var.instance_username
    }
  }
}

resource "random_id" "my_vm" {
  byte_length = 4
}
```

## Custom Cloud-Init Configuration

Create custom user data for specific use cases:

```yaml
#cloud-config
hostname: my-custom-vm
preserve_hostname: false

users:
  - name: myuser
    groups: sudo
    ssh_authorized_keys:
      - ssh-rsa AAAAB3...

packages:
  - docker.io
  - docker-compose

runcmd:
  # Ensure unique identity
  - rm -f /etc/machine-id
  - systemd-machine-id-setup

  # Custom application setup
  - systemctl enable docker
  - systemctl start docker
  - usermod -aG docker myuser
```

## Troubleshooting

### VM Won't Start After Cloning
- Check that VM ID is unique
- Ensure sufficient resources on target node
- Verify cloud-init configuration syntax

### IP Address Conflicts
- Ensure DHCP is properly configured
- Check that MAC addresses are unique (auto-generated)
- Restart network services: `systemctl restart systemd-networkd`

### SSH Connection Issues
- Wait for cloud-init to complete (check `/var/log/cloud-init.log`)
- Verify SSH keys are correctly configured
- Check firewall rules: `ufw status`

### Template Update Process
1. Create new VM from current template
2. Make desired changes
3. Clean the VM: `cloud-init clean`
4. Shutdown the VM
5. Convert to template: `qm template <vmid>`

## Best Practices

1. **Always use DHCP** for IP assignment to prevent conflicts
2. **Don't hardcode MAC addresses** - let Proxmox generate them
3. **Use unique VM names** with random suffixes
4. **Test template changes** before applying to production
5. **Regular updates** - rebuild template monthly for security updates
6. **Monitor resources** - ensure sufficient capacity on target nodes

## Security Considerations

- SSH keys are automatically generated and managed by Terraform
- Default passwords should be changed after first login
- Firewall is enabled by default - adjust rules as needed
- Fail2ban protects against SSH brute force attacks
- Machine IDs are regenerated to prevent identity conflicts

## Maintenance

### Updating the Template
```bash
# Update cloud image
terraform apply -target=proxmox_virtual_environment_download_file.debian_cloud_image

# Rebuild template
terraform taint proxmox_virtual_environment_vm.debian_cloud_template
terraform apply -target=proxmox_virtual_environment_vm.debian_cloud_template
```

### Cleanup
```bash
# Remove example VMs
terraform destroy -target=proxmox_virtual_environment_vm.web_server
terraform destroy -target=proxmox_virtual_environment_vm.database_server

# Remove template (careful!)
terraform destroy -target=proxmox_virtual_environment_vm.debian_cloud_template
```
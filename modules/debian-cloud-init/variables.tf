variable "machine_name" {
  description = "Name of VM guest"
  type        = string
}

variable "vm_id" {
  description = "VM ID"
  type        = number
}

variable "node" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve3"
}

variable "datastore" {
  description = "Datastore for VM disk and cloud-init"
  type        = string
  default     = "nfs-backups"
}

variable "template_vm_id" {
  description = "VM ID of the Debian cloud-init template to clone from"
  type        = number
  default     = 9000
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "cpu_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "cpu_type" {
  description = "CPU type"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "network_bridge" {
  description = "Network bridge to use"
  type        = string
  default     = "vmbr0"
}

variable "firewall_enabled" {
  description = "Enable firewall on network interface"
  type        = bool
  default     = true
}

variable "instance_username" {
  description = "Username for the VM instance - pass var.instance_username from root"
  type        = string
}

variable "instance_password" {
  description = "Password for the VM instance - pass var.instance_password from root"
  type        = string
  sensitive   = true
}

variable "create_ssh_key" {
  description = "Create a new SSH key pair for this VM"
  type        = bool
  default     = false
}

variable "ssh_public_key" {
  description = "SSH public key for the VM instance (required if create_ssh_key is false)"
  type        = string
  default     = null
}

variable "ipv4_address" {
  description = "IPv4 address (use 'dhcp' for DHCP or CIDR notation like '192.168.1.100/24')"
  type        = string
  default     = "dhcp"
}

variable "ipv4_gateway" {
  description = "IPv4 gateway (required if using static IP)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to add to the VM"
  type        = list(string)
  default     = []
}

variable "description" {
  description = "VM description"
  type        = string
  default     = "Managed by Terraform"
}

variable "started" {
  description = "Start VM after creation"
  type        = bool
  default     = true
}

variable "on_boot" {
  description = "Start VM on boot"
  type        = bool
  default     = false
}

variable "custom_packages" {
  description = "Additional packages to install via cloud-init"
  type        = list(string)
  default     = []
}

variable "custom_runcmd" {
  description = "Additional commands to run via cloud-init"
  type        = list(string)
  default     = []
}

variable "agent_enabled" {
  description = "Enable QEMU guest agent"
  type        = bool
  default     = true
}

variable "agent_timeout" {
  description = "Timeout for guest agent"
  type        = string
  default     = "15m"
}

locals {
  haos_version = "18.1"
  # Proxmox rejects .qcow2/.raw filenames for content_type = "iso" uploads on PVE < 8.4
  # (see debian_cloud_image in cloud_init_template.tf), so upload under a .img name.
  haos_image_name        = "haos_ova-${local.haos_version}.qcow2"
  haos_image_upload_name = "haos_ova-${local.haos_version}.img"
  haos_image_url         = "https://github.com/home-assistant/operating-system/releases/download/${local.haos_version}/${local.haos_image_name}.xz"
  haos_image_dir         = "${path.module}/images"
  haos_image_path        = "${local.haos_image_dir}/${local.haos_image_name}"
}

# proxmox_virtual_environment_download_file cannot decompress .xz (only gz/lzo/zst/bz2),
# and HAOS is only published as .qcow2.xz, so fetch + decompress locally instead.
resource "null_resource" "haos_image_fetch" {
  triggers = {
    haos_version = local.haos_version
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      mkdir -p "${local.haos_image_dir}"
      if [ ! -f "${local.haos_image_path}" ]; then
        curl -fL --retry 3 -o "${local.haos_image_path}.xz" "${local.haos_image_url}"
        unxz -f "${local.haos_image_path}.xz"
      fi
    EOT
  }
}

resource "proxmox_virtual_environment_file" "haos_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve2"

  source_file {
    path      = local.haos_image_path
    file_name = local.haos_image_upload_name
  }

  depends_on = [null_resource.haos_image_fetch]
}

resource "proxmox_virtual_environment_vm" "haos" {
  name        = "HAOS-HomeAssistant"
  description = "Managed by Terraform - Home Assistant OS ${local.haos_version}"
  tags        = ["terraform", "haos", "home-assistant", "vm"]

  node_name = "pve2"
  vm_id     = 313

  bios    = "ovmf"
  machine = "q35"

  agent {
    enabled = true # HAOS ships qemu-guest-agent; flip on once confirmed responding post-onboarding
  }
  stop_on_destroy = true

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  scsi_hardware = "virtio-scsi-single"

  efi_disk {
    datastore_id      = "local"
    file_format       = "raw"
    type              = "4m"
    pre_enrolled_keys = false
  }

  disk {
    datastore_id = "local"
    file_id      = proxmox_virtual_environment_file.haos_image.id
    file_format  = "qcow2"
    interface    = "scsi0"
    size         = 32
    ssd          = true
    discard      = "on"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  lifecycle {
    ignore_changes = [
      disk[0].file_id,
      efi_disk,
    ]
  }

  depends_on = [proxmox_virtual_environment_file.haos_image]
}

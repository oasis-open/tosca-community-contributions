terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.79.0"  # For supporting 'import_from' in disk element of resource proxmox_virtual_environment_vm
    }
  }
}
variable "url" {
  type = string
}
variable "user_name" {
  type = string
}
variable "proxmox_key_file" {
  type = string
}
variable "public_key_file" {
  type = string
}
variable "api_token_file" {
  type = string
}
variable "node_name" {
  type = string
}
variable "image_id" {
  type = string
}
variable "compute_name" {
  type = string
}
variable "hostname" {
  type    = string
  default = ""
}
variable "domainname" {
  type    = string
  default = ""
}
variable "nameservers" {
  type    = list(string)
  default = []
}
variable "apt_source" {
  type    = string
  default = ""
}
variable "disk_size" {
  type    = number
  default = 8
}
variable "datastore_ids" {
  type = map(string)
}
variable "mem_size" {
  type    = number
  default = 512
}
variable "num_cpus" {
  type    = number
  default = 1
}
variable "cloudinit_template_file" {
  type = string
}

provider "proxmox" {
  endpoint  = var.url
  username  = var.user_name
  api_token = file(var.api_token_file)
  insecure  = true  # Set to false if using a valid SSL certificate
  ssh {
    agent       = false
    username    = var.user_name
    private_key = file(var.proxmox_key_file)
  }
}
resource "proxmox_virtual_environment_file" "user_data" {
  content_type = "snippets"
  datastore_id = var.datastore_ids["snippets"]
  node_name    = var.node_name
  source_raw {
    data = templatefile(var.cloudinit_template_file, {
      hostname        = var.hostname
      domainname      = var.domainname
      nameservers     = var.nameservers
      public_key_file = var.public_key_file
      apt_source      = var.apt_source
    })
    file_name = "user_data.yaml"
  }
}
resource "proxmox_virtual_environment_vm" "ubicity_vm" {
  name      = var.compute_name
  node_name = var.node_name

  # should be true if qemu agent is not installed / enabled on the VM
  stop_on_destroy = true

  agent {
    enabled = true
  }
  initialization {
    datastore_id = var.datastore_ids["images"]
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.user_data.id
  }
  cpu {
    cores        = var.num_cpus
  }
  memory {
    dedicated    = var.mem_size
    floating     = var.mem_size
  }
  disk {
    datastore_id = var.datastore_ids["images"]
    file_id      = strcontains(var.image_id, ":import/") ? null: var.image_id
    file_format  = strcontains(var.image_id, ":import/") ? null: "raw"
    import_from = strcontains(var.image_id, ":import/") ? var.image_id: null
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size
  }
  network_device {
    bridge = "vmbr0"
    model = "virtio"
  }

  # Known issues for Debian 12 / Ubuntu VMs
    # https://github.com/bpg/terraform-provider-proxmox?tab=readme-ov-file#known-issues
    # Fix:
  serial_device {
    device = "socket"
  }
}  
output "public_address" {
  description = "The public IP address of the compute instance."
  value       = proxmox_virtual_environment_vm.ubicity_vm.ipv4_addresses[1][0]
}

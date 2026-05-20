terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.79.0"  # Align with ../image/image.tf and ../compute/compute.tf
    }
  }
}
variable "url" {
  type = string
}
variable "user_name" {
  type = string
}
variable "key_file" {
  type = string
}
variable "api_token_file" {
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
    private_key = file(var.key_file)
  }
}
resource "proxmox_virtual_environment_user" "user" {
  user_id         = "ubicity@pve"
  password	  = "Ubicity1!"
  comment         = "Managed by Terraform"
  email           = "ubicity@pve"
  enabled         = true
}

resource "proxmox_virtual_environment_user_token" "user_token" {
  comment         = "Managed by Terraform"
  token_name      = "ubct-token"
  user_id         = proxmox_virtual_environment_user.user.user_id
}

resource "local_file" "ubct_token_file" {
  filename = "/home/lauwers/vault/proxmox_ubct_token.txt"  # Change this to your desired directory
  content  = "API Token: ${proxmox_virtual_environment_user_token.ubicity_token.value}"
  file_permission = "0600"  # Restrict permissions for security
}


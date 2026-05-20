terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.79.0"  # For supporting 'import' content_type in resource proxmox_virtual_environment_file
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
variable "node_name" {
  type = string
}
variable "cloud_image_url" {
  type = string
  default = ""
}
variable "local_image_path" {
  type = string
  default = ""
}
variable "datastore_ids" {
  type = map(string)
}
variable "datastore_filename" {
  type = string
  default = ""
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
# Upload local image (if local_image_path is given)
resource "proxmox_virtual_environment_file" "cloud_image_local" {
  count         = var.local_image_path != "" ? 1 : 0
  content_type  = "iso"
  datastore_id  = var.datastore_ids["iso"]
  node_name     = var.node_name
  source_file {
    path = var.local_image_path
    file_name = var.datastore_filename
  }
}
resource "proxmox_virtual_environment_download_file" "cloud_image_remote" {
  count         = var.cloud_image_url != "" ? 1 : 0
  content_type  = "iso"
  datastore_id  = var.datastore_ids["iso"]
  overwrite_unmanaged = true
  node_name     = var.node_name
  file_name = var.datastore_filename
  url           = var.cloud_image_url
}
output "id" {
  description = "The ID of the cloud image"
  value = (
    var.local_image_path != "" ? proxmox_virtual_environment_file.cloud_image_local[0].id :
    var.cloud_image_url != "" ? proxmox_virtual_environment_download_file.cloud_image_remote[0].id :
    var.datastore_filename != "" ? "${var.datastore_ids["iso"]}:import/${var.datastore_filename}" : null
  )
}

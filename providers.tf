provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_api_token == "" ? var.proxmox_username : null
  password = var.proxmox_api_token == "" ? var.proxmox_password : null
  api_token = var.proxmox_api_token != "" ? var.proxmox_api_token : null
  insecure = var.proxmox_insecure

  ssh {
    agent = false
  }
}

provider "talos" {}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.7.1"
    }
  }
}

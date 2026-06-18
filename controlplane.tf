# =============================================================================
# VMs Control Plane
# Cada nodo se define individualmente en terraform.tfvars
# =============================================================================

resource "proxmox_virtual_environment_vm" "controlplane" {
  for_each = { for n in var.controlplane_nodes : n.name => n }

  name      = each.value.name
  node_name = each.value.proxmox_node
  vm_id     = each.value.vm_id

  description = "Talos Control Plane Node - ${each.value.name}"
  tags        = ["master", var.cluster_name]

  machine = "q35"

  # Boot desde CD-ROM (ISO de Talos)
  boot_order = ["scsi0", "ide0"]

  # CPU
  cpu {
    cores = each.value.cpu
    type  = "x86-64-v2-AES"
  }

  # Memoria
  memory {
    dedicated = each.value.memory
  }

  # Disco del sistema
  disk {
    datastore_id = var.proxmox_disk_datastore
    size         = each.value.disk_size
    interface    = "scsi0"
    file_format  = "raw"
    ssd          = true
    discard      = "on"
  }

  # ISO de Talos
  cdrom {
    file_id   = proxmox_virtual_environment_download_file.talos_iso[each.value.proxmox_node].id
    interface = "ide0"
  }

  # Red
  network_device {
    bridge = var.network_bridge
  }

  # IP estática vía cloud-init network-config (nocloud)
  initialization {
    datastore_id = var.proxmox_disk_datastore

    ip_config {
      ipv4 {
        address = "${each.value.ip}/${var.node_subnet_prefix}"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.nameservers
    }
  }

  agent {
    enabled = true
  }

  on_boot = true

  lifecycle {
    ignore_changes = [
      boot_order,
      cdrom,
    ]
  }
}

# =============================================================================
# Aplicar configuración Talos a cada nodo Control Plane
# =============================================================================

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = { for n in var.controlplane_nodes : n.name => n }

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration

  endpoint = each.value.ip
  node     = each.value.ip

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.value.name
          interfaces = [
            {
              interface = "eth0"
              addresses = ["${each.value.ip}/${var.node_subnet_prefix}"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.gateway
                }
              ]
              vip = {
                ip = var.cluster_endpoint
              }
            }
          ]
        }
      }
    })
  ]

  depends_on = [
    proxmox_virtual_environment_vm.controlplane
  ]
}

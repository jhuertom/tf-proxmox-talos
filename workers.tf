# =============================================================================
# VMs Worker
# Se distribuyen en round-robin entre los nodos Proxmox
# =============================================================================

resource "proxmox_virtual_environment_vm" "worker" {
  count = var.worker_count

  name      = "${var.cluster_name}-worker-${count.index}"
  node_name = var.proxmox_nodes[count.index % length(var.proxmox_nodes)]
  vm_id     = var.worker_vm_id_start + count.index

  description = "Talos Worker Node ${count.index} - ${var.cluster_name}"
  tags        = ["worker", var.cluster_name]

  machine = "q35"

  # Boot desde CD-ROM (ISO de Talos)
  boot_order = ["scsi0", "ide0"]

  # CPU
  cpu {
    cores = var.worker_cpu
    type  = "x86-64-v2-AES"
  }

  # Memoria
  memory {
    dedicated = var.worker_memory
  }

  # Disco del sistema
  disk {
    datastore_id = var.proxmox_disk_datastore
    size         = var.worker_disk_size
    interface    = "scsi0"
    file_format  = "raw"
    ssd          = true
    discard      = "on"
  }

  # ISO de Talos
  cdrom {
    file_id   = proxmox_virtual_environment_download_file.talos_iso[var.proxmox_nodes[count.index % length(var.proxmox_nodes)]].id
    interface = "ide0"
  }

  network_device {
    bridge = var.network_bridge
  }

  # IP estática vía cloud-init network-config (nocloud)
  initialization {
    datastore_id = var.proxmox_disk_datastore

    ip_config {
      ipv4 {
        address = "${var.worker_ips[count.index]}/24"
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
# Aplicar configuración Talos a cada nodo Worker
# =============================================================================

resource "talos_machine_configuration_apply" "worker" {
  count = var.worker_count

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration

  endpoint = var.worker_ips[count.index]
  node     = var.worker_ips[count.index]

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = "${var.cluster_name}-worker-${count.index}"
          interfaces = [
            {
              interface = "eth0"
              addresses = ["${var.worker_ips[count.index]}/24"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.gateway
                }
              ]
            }
          ]
        }
      }
    })
  ]

  depends_on = [
    proxmox_virtual_environment_vm.worker
  ]
}

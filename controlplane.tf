# =============================================================================
# VMs Control Plane
# Se distribuyen en round-robin entre los nodos Proxmox
# =============================================================================

resource "proxmox_virtual_environment_vm" "controlplane" {
  count = var.controlplane_count

  name      = "${var.cluster_name}-cp-${count.index}"
  node_name = var.proxmox_nodes[count.index % length(var.proxmox_nodes)]
  vm_id     = var.controlplane_vm_id_start + count.index

  description = "Talos Control Plane Node ${count.index} - ${var.cluster_name}"
  tags        = ["master", var.cluster_name]

  machine = "q35"

  # Boot desde CD-ROM (ISO de Talos)
  boot_order = ["scsi0", "ide0"]

  # CPU
  cpu {
    cores = var.controlplane_cpu
    type  = "x86-64-v2-AES"
  }

  # Memoria
  memory {
    dedicated = var.controlplane_memory
  }

  # Disco del sistema
  disk {
    datastore_id = var.proxmox_disk_datastore
    size         = var.controlplane_disk_size
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

  # Red - conectada a la VNet SDN (10.0.0.0/24)
  network_device {
    bridge = var.network_bridge
  }

  # IP estática vía cloud-init network-config (nocloud)
  # Talos lee el network-config del datasource nocloud al arrancar
  initialization {
    datastore_id = var.proxmox_disk_datastore

    ip_config {
      ipv4 {
        address = "${var.controlplane_ips[count.index]}/24"
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

  # Sin cloud-init, Talos se configura vía su propia API
  on_boot = true

  # Esperar a que la VM arranque antes de aplicar configuración
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
  count = var.controlplane_count

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration

  endpoint = var.controlplane_ips[count.index]
  node     = var.controlplane_ips[count.index]

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = "${var.cluster_name}-cp-${count.index}"
          interfaces = [
            {
              interface = "eth0"
              addresses = ["${var.controlplane_ips[count.index]}/24"]
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

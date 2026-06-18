# =============================================================================
# Secretos del clúster Talos (certificados, tokens, claves)
# =============================================================================

resource "talos_machine_secrets" "this" {}

# =============================================================================
# Configuración del cliente talosctl
# =============================================================================

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for n in var.controlplane_nodes : n.ip]
  nodes                = concat([for n in var.controlplane_nodes : n.ip], [for n in var.worker_nodes : n.ip])
}

# =============================================================================
# Configuración base de máquinas Control Plane
# =============================================================================

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = "https://${var.cluster_endpoint}:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/${var.talos_schematic_id}:${var.talos_version}"
          disk  = "/dev/sda"
        }
        network = {
          nameservers = var.nameservers
        }
        features = {
          kubePrism = {
            enabled = true
            port    = 7445
          }
        }
      }
      cluster = {
        network = {
          cni = {
            name = "none"
          }
        }
        allowSchedulingOnControlPlanes = false
        proxy = {
          disabled = true
        }
      }
    })
  ]
}

# =============================================================================
# Configuración base de máquinas Worker
# =============================================================================

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = "https://${var.cluster_endpoint}:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/${var.talos_schematic_id}:${var.talos_version}"
          disk  = "/dev/sda"
        }
        network = {
          nameservers = var.nameservers
        }
        features = {
          kubePrism = {
            enabled = true
            port    = 7445
          }
        }
      }
    })
  ]
}

# =============================================================================
# Bootstrap del clúster Talos
# Se ejecuta en el primer nodo control plane
# =============================================================================

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.controlplane_ips[0]
  node                 = var.controlplane_ips[0]

  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]
}

# =============================================================================
# Esperar a que el clúster esté sano
# =============================================================================

data "talos_cluster_health" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  control_plane_nodes  = var.controlplane_ips
  worker_nodes         = var.worker_ips
  endpoints            = var.controlplane_ips

  timeouts = {
    read = "10m"
  }

  skip_kubernetes_checks = true

  depends_on = [
    talos_machine_bootstrap.this,
    talos_machine_configuration_apply.worker
  ]
}

# =============================================================================
# Obtener kubeconfig del clúster
# =============================================================================

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.controlplane_ips[0]
  node                 = var.controlplane_ips[0]

  depends_on = [
    data.talos_cluster_health.this
  ]
}

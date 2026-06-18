# =============================================================================
# Bootstrap del clúster Talos
# Se ejecuta en el primer nodo control plane
# =============================================================================

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.controlplane_nodes[0].ip
  node                 = var.controlplane_nodes[0].ip

  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]
}

# =============================================================================
# Obtener kubeconfig del clúster
# =============================================================================

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.controlplane_nodes[0].ip
  node                 = var.controlplane_nodes[0].ip

  depends_on = [
    talos_machine_bootstrap.this,
    talos_machine_configuration_apply.worker
  ]
}

# =============================================================================
# Escribir kubeconfig a disco para uso por herramientas externas (helm, kubectl)
# =============================================================================

resource "local_file" "kubeconfig" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = "${path.module}/kubeconfig"
  file_permission = "0600"
}

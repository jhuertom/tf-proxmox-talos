# =============================================================================
# Cleanup de nodos Kubernetes al destruir VMs
# Cada null_resource se destruye junto con su VM, ejecutando kubectl delete node
# =============================================================================

resource "null_resource" "controlplane_k8s_cleanup" {
  for_each = { for n in var.controlplane_nodes : n.name => n }

  triggers = {
    name = each.value.name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      export KUBECONFIG="${path.module}/kubeconfig"
      if kubectl cluster-info >/dev/null 2>&1; then
        kubectl delete node ${self.triggers.name} --ignore-not-found=true
      else
        echo "Cluster not reachable, skipping node deletion for ${self.triggers.name}"
      fi
    EOT
  }

  depends_on = [
    local_file.kubeconfig
  ]
}

resource "null_resource" "worker_k8s_cleanup" {
  for_each = { for n in var.worker_nodes : n.name => n }

  triggers = {
    name = each.value.name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      export KUBECONFIG="${path.module}/kubeconfig"
      if kubectl cluster-info >/dev/null 2>&1; then
        kubectl delete node ${self.triggers.name} --ignore-not-found=true
      else
        echo "Cluster not reachable, skipping node deletion for ${self.triggers.name}"
      fi
    EOT
  }

  depends_on = [
    local_file.kubeconfig
  ]
}

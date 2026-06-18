# =============================================================================
# Instalación de Cilium (CNI) via Helm, gestionada por Terraform
# =============================================================================
# Se ejecuta automáticamente tras obtener el kubeconfig del clúster.
# Si cambia manifests/cilium-values.yaml, Terraform re-ejecutará la instalación.
# =============================================================================

resource "null_resource" "cilium" {
  triggers = {
    values_hash = filemd5("${path.module}/manifests/cilium-values.yaml")
  }

  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG="${path.module}/kubeconfig"

      # Esperar a que el API server del clúster esté accesible
      echo "Waiting for cluster endpoint to be reachable..."
      for i in $(seq 1 60); do
        if kubectl cluster-info >/dev/null 2>&1; then
          echo "Cluster is reachable"
          break
        fi
        echo "  attempt $i/60: cluster not yet reachable..."
        sleep 5
        if [ $i -eq 60 ]; then
          echo "ERROR: cluster endpoint never became reachable"
          exit 1
        fi
      done

      helm repo add cilium https://helm.cilium.io/ 2>/dev/null || true
      helm repo update
      if helm status cilium -n kube-system >/dev/null 2>&1; then
        echo "Cilium already installed, upgrading..."
        helm upgrade cilium cilium/cilium \
          --namespace kube-system \
          --values "${path.module}/manifests/cilium-values.yaml" \
          --wait \
          --wait-for-jobs
      else
        echo "Installing Cilium..."
        helm install cilium cilium/cilium \
          --namespace kube-system \
          --create-namespace \
          --values "${path.module}/manifests/cilium-values.yaml" \
          --wait \
          --wait-for-jobs
      fi
    EOT
  }

  depends_on = [
    local_file.kubeconfig,
  ]
}

#!/usr/bin/env bash
# =============================================================================
# Instalación de Cilium en clúster Talos
# =============================================================================
# Requisitos:
#   - Helm 3 instalado
#   - kubeconfig disponible (export KUBECONFIG=...)
#   - Clúster Talos bootstrappeado
#
# Uso:
#   export KUBECONFIG=/ruta/a/kubeconfig
#   ./manifests/install-cilium.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="${SCRIPT_DIR}/cilium-values.yaml"

if ! command -v helm &> /dev/null; then
    echo "ERROR: helm no está instalado. Instálalo desde https://helm.sh/docs/intro/install/"
    exit 1
fi

if [ -z "${KUBECONFIG:-}" ]; then
    echo "WARNING: KUBECONFIG no está definido. Usando ~/.kube/config por defecto."
fi

echo "Adding Cilium Helm repo..."
helm repo add cilium https://helm.cilium.io/ 2>/dev/null || true
helm repo update

echo "Installing Cilium..."
helm install cilium cilium/cilium \
    --namespace kube-system \
    --create-namespace \
    --values "${VALUES_FILE}" \
    --wait \
    --wait-for-jobs

echo ""
echo "Cilium installed successfully."
echo ""
echo "Verificar estado:"
echo "  kubectl get pods -n kube-system -l k8s-app=cilium"
echo ""
echo "Esperar a que los nodos pasen a Ready (1-2 min):"
echo "  watch kubectl get nodes"

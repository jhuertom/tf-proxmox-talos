# =============================================================================
# Outputs del clúster
# =============================================================================

output "talosconfig" {
  description = "Configuración del cliente talosctl. Guardar en ~/.talos/config"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubeconfig para kubectl. Guardar en ~/.kube/config"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "controlplane_ips" {
  description = "IPs de los nodos control plane"
  value       = var.controlplane_ips
}

output "worker_ips" {
  description = "IPs de los nodos worker"
  value       = var.worker_ips
}

output "cluster_endpoint" {
  description = "Endpoint del API server de Kubernetes (VIP)"
  value       = "https://${var.cluster_endpoint}:6443"
}

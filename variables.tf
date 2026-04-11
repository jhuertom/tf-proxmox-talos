# =============================================================================
# Proxmox Connection
# =============================================================================

variable "proxmox_endpoint" {
  description = "URL del endpoint de la API de Proxmox (ej: https://proxmox.local:8006/)"
  type        = string
}

variable "proxmox_api_token" {
  description = "API Token de Proxmox en formato 'usuario@realm!tokenid=token-secret'"
  type        = string
  sensitive   = true
  default     = ""
}

variable "proxmox_username" {
  description = "Usuario de Proxmox (ej: root@pam). Se usa si no se proporciona api_token."
  type        = string
  default     = "root@pam"
}

variable "proxmox_password" {
  description = "Contraseña de Proxmox. Se usa si no se proporciona api_token."
  type        = string
  sensitive   = true
  default     = ""
}

variable "proxmox_insecure" {
  description = "Permitir certificados TLS auto-firmados en Proxmox"
  type        = bool
  default     = true
}

# =============================================================================
# Proxmox Infrastructure
# =============================================================================

variable "proxmox_nodes" {
  description = "Lista de nodos Proxmox donde distribuir las VMs"
  type        = list(string)
  default     = ["roman", "antonio", "jacinta"]
}

variable "proxmox_iso_datastore" {
  description = "Datastore de Proxmox para almacenar la ISO de Talos"
  type        = string
  default     = "local"
}

variable "proxmox_disk_datastore" {
  description = "Datastore de Proxmox para los discos de las VMs"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Bridge de red de Proxmox para las VMs"
  type        = string
  default     = "vmbr0"
}

# =============================================================================
# Talos Configuration
# =============================================================================

variable "talos_version" {
  description = "Versión de Talos Linux a desplegar"
  type        = string
  default     = "v1.11.6"
}

variable "talos_schematic_id" {
  description = "Schematic ID de Talos Image Factory (incluye extensiones como qemu-guest-agent)"
  type        = string
  default     = "ddf38e55e30aa9b2bb0b765054ed63444dc00244ab8bb4ad4ad92486602285f8"
}

# =============================================================================
# Cluster Configuration
# =============================================================================

variable "cluster_name" {
  description = "Nombre del clúster de Kubernetes"
  type        = string
  default     = "talos-proxmox"
}

variable "cluster_endpoint" {
  description = "IP virtual (VIP) para el endpoint del API server de Kubernetes"
  type        = string
  default     = "10.0.0.10"
}

variable "gateway" {
  description = "Gateway de la red"
  type        = string
  default     = "10.0.0.1"
}

variable "node_subnet_prefix" {
  description = "Longitud del prefijo de subred para los nodos (ej: 23 para /23)"
  type        = number
  default     = 23
}

variable "nameservers" {
  description = "Servidores DNS"
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}

# =============================================================================
# Control Plane Nodes
# =============================================================================

variable "controlplane_count" {
  description = "Número de nodos control plane"
  type        = number
  default     = 3
}

variable "controlplane_ips" {
  description = "IPs de los nodos control plane (deben coincidir con controlplane_count)"
  type        = list(string)
  default     = ["10.0.0.11", "10.0.0.12", "10.0.0.13"]
}

variable "controlplane_cpu" {
  description = "Número de cores de CPU para nodos control plane"
  type        = number
  default     = 2
}

variable "controlplane_memory" {
  description = "Memoria RAM en MB para nodos control plane"
  type        = number
  default     = 4096
}

variable "controlplane_disk_size" {
  description = "Tamaño del disco en GB para nodos control plane"
  type        = number
  default     = 20
}

variable "controlplane_vm_id_start" {
  description = "ID de VM inicial para los nodos control plane"
  type        = number
  default     = 200
}

# =============================================================================
# Worker Nodes
# =============================================================================

variable "worker_count" {
  description = "Número de nodos worker"
  type        = number
  default     = 3
}

variable "worker_ips" {
  description = "IPs de los nodos worker (deben coincidir con worker_count)"
  type        = list(string)
  default     = ["10.0.0.21", "10.0.0.22", "10.0.0.23"]
}

variable "worker_cpu" {
  description = "Número de cores de CPU para nodos worker"
  type        = number
  default     = 2
}

variable "worker_memory" {
  description = "Memoria RAM en MB para nodos worker"
  type        = number
  default     = 4096
}

variable "worker_disk_size" {
  description = "Tamaño del disco en GB para nodos worker"
  type        = number
  default     = 50
}

variable "worker_vm_id_start" {
  description = "ID de VM inicial para los nodos worker"
  type        = number
  default     = 210
}

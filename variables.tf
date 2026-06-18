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

variable "controlplane_nodes" {
  description = "Lista de nodos control plane con sus atributos individuales"
  type = list(object({
    name         = string
    ip           = string
    proxmox_node = string
    cpu          = number
    memory       = number
    disk_size    = number
    vm_id        = number
  }))
}

# =============================================================================
# Worker Nodes
# =============================================================================

variable "worker_nodes" {
  description = "Lista de nodos worker con sus atributos individuales"
  type = list(object({
    name         = string
    ip           = string
    proxmox_node = string
    cpu          = number
    memory       = number
    disk_size    = number
    vm_id        = number
  }))
}

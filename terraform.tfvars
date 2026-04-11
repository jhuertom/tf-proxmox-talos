# =============================================================================
# Proxmox Connection
# Configura las credenciales como variables de entorno:
#   export TF_VAR_proxmox_endpoint="https://tu-proxmox:8006/"
#   export TF_VAR_proxmox_password="tu-password"
#   O bien:
#   export TF_VAR_proxmox_api_token="user@realm!tokenid=secret"
# =============================================================================

proxmox_endpoint = "https://192.168.2.241:8006/"
proxmox_insecure = true

# =============================================================================
# Proxmox Infrastructure
# =============================================================================

proxmox_nodes          = ["roman", "antonio", "jacinta"]
proxmox_iso_datastore  = "local"
proxmox_disk_datastore = "local-lvm"
network_bridge         = "vmbr0"

# =============================================================================
# Talos Configuration
# =============================================================================

talos_version      = "v1.11.6"
talos_schematic_id = "ddf38e55e30aa9b2bb0b765054ed63444dc00244ab8bb4ad4ad92486602285f8"

# =============================================================================
# Cluster Configuration
# =============================================================================

cluster_name     = "production"
# El cluster_endpoint es una IP Virtual (VIP) que Talos gestiona automáticamente 
#    entre los nodos control plane. Es la IP que usarás para conectarte al API 
#    server de Kubernetes.
cluster_endpoint = "192.168.2.210"
gateway          = "192.168.2.1"
nameservers      = ["1.1.1.1", "8.8.8.8"]

# =============================================================================
# Control Plane Nodes (3 nodos, 1 por host Proxmox)
# =============================================================================

controlplane_count     = 3
controlplane_ips       = ["192.168.2.211", "192.168.2.212", "192.168.2.213"]
controlplane_cpu       = 2
controlplane_memory    = 4096
controlplane_disk_size = 20
controlplane_vm_id_start = 200

# =============================================================================
# Worker Nodes (3 nodos, 1 por host Proxmox)
# =============================================================================

worker_count     = 3
worker_ips       = ["192.168.2.231", "192.168.2.232", "192.168.2.233"]
worker_cpu       = 2
worker_memory    = 4096
worker_disk_size = 50
worker_vm_id_start = 210

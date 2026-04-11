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
cluster_endpoint = "192.168.3.250"
gateway             = "192.168.2.1"
node_subnet_prefix  = 23
#nameservers         = ["1.1.1.1", "8.8.8.8"]
nameservers         = ["192.168.2.1"]

# =============================================================================
# Control Plane Nodes (3 nodos, 1 por host Proxmox)
# =============================================================================

controlplane_count     = 3
controlplane_ips       = ["192.168.3.251", "192.168.3.252", "192.168.3.253"]
controlplane_cpu       = 2
controlplane_memory    = 4096
controlplane_disk_size = 20
controlplane_vm_id_start = 200

# =============================================================================
# Worker Nodes (3 nodos, 1 por host Proxmox)
# =============================================================================

worker_count     = 3
worker_ips       = ["192.168.3.240", "192.168.3.241", "192.168.3.242"]
worker_cpu       = 2
worker_memory    = 4096
worker_disk_size = 50
worker_vm_id_start = 210

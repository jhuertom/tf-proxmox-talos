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

proxmox_iso_datastore  = "local"
proxmox_disk_datastore = "local-lvm"
network_bridge         = "vmbr0"

# =============================================================================
# Talos Configuration
# =============================================================================

talos_version      = "v1.13.4"
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

controlplane_nodes = [
  { name = "production-cp-0", ip = "192.168.3.251", proxmox_node = "maria",   cpu = 6, memory = 16384, disk_size = 20, vm_id = 200 },
  { name = "production-cp-1", ip = "192.168.3.252", proxmox_node = "jacinta", cpu = 6, memory = 16384, disk_size = 20, vm_id = 201 },
  { name = "production-cp-2", ip = "192.168.3.253", proxmox_node = "celia",   cpu = 6, memory = 8192, disk_size = 20, vm_id = 202 },
]

# =============================================================================
# Worker Nodes (3 nodos, 1 por host Proxmox)
# =============================================================================

worker_nodes = [
  { name = "production-worker-0", ip = "192.168.3.240", proxmox_node = "maria",   cpu = 6, memory = 16384, disk_size = 50, vm_id = 210 },
  { name = "production-worker-1", ip = "192.168.3.241", proxmox_node = "jacinta", cpu = 6, memory = 16384, disk_size = 50, vm_id = 211 },
  { name = "production-worker-2", ip = "192.168.3.242", proxmox_node = "celia",   cpu = 6, memory = 8192, disk_size = 50, vm_id = 212 },
]

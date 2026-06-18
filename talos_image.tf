# =============================================================================
# Descarga de la ISO de Talos desde Image Factory
# Se descarga en cada nodo Proxmox para evitar problemas de almacenamiento compartido
# =============================================================================

resource "proxmox_virtual_environment_download_file" "talos_iso" {
  for_each = toset(concat(
    [for n in var.controlplane_nodes : n.proxmox_node],
    [for n in var.worker_nodes : n.proxmox_node]
  ))

  content_type = "iso"
  datastore_id = var.proxmox_iso_datastore
  node_name    = each.value

  url                   = "https://factory.talos.dev/image/${var.talos_schematic_id}/${var.talos_version}/nocloud-amd64.iso"
  file_name             = "talos-${var.talos_version}-nocloud-amd64.iso"
  overwrite             = true
  overwrite_unmanaged   = true
}

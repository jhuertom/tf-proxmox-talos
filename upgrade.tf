# =============================================================================
# Talos OS Upgrade Automation
# Cuando cambia talos_version o talos_schematic_id, se ejecuta talosctl upgrade
# =============================================================================

# =============================================================================
# talosconfig generado dinámicamente desde los secretos del clúster actual
# =============================================================================
resource "local_file" "talosconfig" {
  content         = data.talos_client_configuration.this.talos_config
  filename        = "${path.module}/talosconfig"
  file_permission = "0600"
}

# Upgrade secuencial de nodos control plane
resource "null_resource" "controlplane_upgrade" {
  triggers = {
    talos_version      = var.talos_version
    talos_schematic_id = var.talos_schematic_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      export TALOSCONFIG="${path.module}/talosconfig"

      UPGRADE_NODE() {
        local NAME="$1"
        local IP="$2"
        local TARGET="${var.talos_version}"
        local OUT

        # Retry hasta 2 min esperando a que el nodo responda por API
        echo "Waiting for $NAME ($IP) to be reachable..."
        for i in $(seq 1 24); do
          OUT=$(talosctl version --nodes "$IP" 2>&1)
          if [ $? -eq 0 ]; then
            break
          fi
          echo "  attempt $i/24: $NAME not yet reachable..."
          sleep 5
          if [ $i -eq 24 ]; then
            echo "ERROR: $NAME never became reachable"
            return 1
          fi
        done

        local CURRENT=$(echo "$OUT" | awk '/^Server:/{found=1} found && /Tag:/{print $2; exit}')
        if [ "$CURRENT" = "$TARGET" ]; then
          echo "$NAME already at $TARGET, skipping"
          return 0
        fi
        echo "Upgrading $NAME ($IP) to $TARGET..."
        talosctl upgrade --nodes "$IP" --image factory.talos.dev/installer/${var.talos_schematic_id}:${var.talos_version}
        if [ $? -ne 0 ]; then
          echo "ERROR: talosctl upgrade failed for $NAME"
          return 1
        fi
        echo "Waiting for $NAME to come back with $TARGET..."
        for i in $(seq 1 24); do
          sleep 15
          OUT=$(talosctl version --nodes "$IP" 2>&1)
          if [ $? -ne 0 ]; then
            echo "  attempt $i/24: $NAME not yet reachable..."
            continue
          fi
          local NOW=$(echo "$OUT" | awk '/^Server:/{found=1} found && /Tag:/{print $2; exit}')
          if [ "$NOW" = "$TARGET" ]; then
            echo "$NAME upgraded successfully to $TARGET"
            return 0
          fi
          echo "  attempt $i/24: $NAME at $NOW, still waiting..."
        done
        echo "ERROR: $NAME did not reach $TARGET after 24 attempts (~6 min)"
        return 1
      }

      %{ for node in var.controlplane_nodes }
      UPGRADE_NODE "${node.name}" "${node.ip}" || exit 1
      %{ endfor }
    EOT
  }

  depends_on = [
    local_file.talosconfig,
    talos_machine_configuration_apply.controlplane,
  ]
}

# Upgrade paralelo de nodos worker
resource "null_resource" "worker_upgrade" {
  for_each = { for n in var.worker_nodes : n.name => n }

  triggers = {
    talos_version      = var.talos_version
    talos_schematic_id = var.talos_schematic_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      export TALOSCONFIG="${path.module}/talosconfig"

      NAME="${each.value.name}"
      IP="${each.value.ip}"
      TARGET="${var.talos_version}"

      # Retry hasta 2 min esperando a que el nodo responda por API
      echo "Waiting for $NAME ($IP) to be reachable..."
      for i in $(seq 1 24); do
        OUT=$(talosctl version --nodes "$IP" 2>&1)
        if [ $? -eq 0 ]; then
          break
        fi
        echo "  attempt $i/24: $NAME not yet reachable..."
        sleep 5
        if [ $i -eq 24 ]; then
          echo "ERROR: $NAME never became reachable"
          exit 1
        fi
      done

      CURRENT=$(echo "$OUT" | awk '/^Server:/{found=1} found && /Tag:/{print $2; exit}')
      if [ "$CURRENT" = "$TARGET" ]; then
        echo "$NAME already at $TARGET, skipping"
        exit 0
      fi
      echo "Upgrading $NAME ($IP) to $TARGET..."
      talosctl upgrade --nodes "$IP" --image factory.talos.dev/installer/${var.talos_schematic_id}:${var.talos_version}
      if [ $? -ne 0 ]; then
        echo "ERROR: talosctl upgrade failed for $NAME"
        exit 1
      fi
      echo "Waiting for $NAME to come back with $TARGET..."
      for i in $(seq 1 24); do
        sleep 15
        OUT=$(talosctl version --nodes "$IP" 2>&1)
        if [ $? -ne 0 ]; then
          echo "  attempt $i/24: $NAME not yet reachable..."
          continue
        fi
        NOW=$(echo "$OUT" | awk '/^Server:/{found=1} found && /Tag:/{print $2; exit}')
        if [ "$NOW" = "$TARGET" ]; then
          echo "$NAME upgraded successfully to $TARGET"
          exit 0
        fi
        echo "  attempt $i/24: $NAME at $NOW, still waiting..."
      done
      echo "ERROR: $NAME did not reach $TARGET after 24 attempts (~6 min)"
      exit 1
    EOT
  }

  depends_on = [
    local_file.talosconfig,
    null_resource.controlplane_upgrade,
    talos_machine_configuration_apply.worker,
  ]
}

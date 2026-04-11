## Paso 1: Configurar Credenciales
```bash
export TF_VAR_proxmox_endpoint="https://192.168.2.X:8006/"
export TF_VAR_proxmox_username="root@pam"
export TF_VAR_proxmox_password="tu-contraseña"
```

### Opción B: API Token (recomendado)

Crear el token en Proxmox: **Datacenter → Permissions → API Tokens → Add**

```bash
export TF_VAR_proxmox_endpoint="https://192.168.2.X:8006/"
export TF_VAR_proxmox_api_token="usuario@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

---

## Paso 2: Personalizar variables

Editar `terraform.tfvars` según tu entorno. Los valores por defecto están pre-configurados.

---

## Paso 3: Desplegar

```bash
# Inicializar providers
terraform init

# Ver el plan de ejecución
terraform plan

# Aplicar (despliega todo: VMs + configuración + bootstrap)
terraform apply
```

El proceso tarda entre 5-15 minutos dependiendo del hardware.

---

## Paso 4: Acceder al clúster

```bash
# Guardar talosconfig
terraform output -raw talosconfig > ~/.talos/config

# Guardar kubeconfig
terraform output -raw kubeconfig > ~/.kube/config

# Verificar el clúster
talosctl health
kubectl get nodes
```
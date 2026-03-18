project_name = "cloudtf"
environment  = "dev"
location     = "eastus"

vnet_address_space          = ["10.20.0.0/16"]
aks_subnet_address_prefixes = ["10.20.1.0/24"]

node_count         = 1
node_vm_size       = "Standard_D2s_v5"
kubernetes_version = null

service_cidr       = "10.21.0.0/16"
dns_service_ip     = "10.21.0.10"
docker_bridge_cidr = "172.17.0.1/16"

authorized_ip_ranges = []

tags = {
  owner       = "platform-team"
  cost_center = "devops-lab"
}

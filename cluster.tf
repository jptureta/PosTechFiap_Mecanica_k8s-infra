# ─────────────────────────────────────────────────────────────
# Cluster Kubernetes local (kind)
# 1 control-plane + 1 worker, com portas expostas para acessar
# a API da aplicação via NodePort a partir da máquina host.
# ─────────────────────────────────────────────────────────────

resource "kind_cluster" "oficina" {
  name            = var.cluster_name
  wait_for_ready  = true
  kubeconfig_path = pathexpand("~/.kube/config-${var.cluster_name}")

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # Mapeia o NodePort 30000 do api-service.yaml para o host,
      # permitindo consumir a API em http://localhost:8000
      extra_port_mappings {
        container_port = 30000
        host_port      = 8000
        protocol       = "TCP"
      }
    }

    node {
      role = "worker"
    }
  }
}

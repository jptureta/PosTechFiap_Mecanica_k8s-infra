output "cluster_name" {
  description = "Nome do cluster kind criado"
  value       = kind_cluster.oficina.name
}

output "kubeconfig_path" {
  description = "Caminho do kubeconfig gerado para acessar o cluster"
  value       = kind_cluster.oficina.kubeconfig_path
}

output "cluster_endpoint" {
  description = "Endpoint da API do Kubernetes"
  value       = kind_cluster.oficina.endpoint
}

output "database_service" {
  description = "Endereço interno do banco para uso pela aplicação"
  value       = "db.${var.namespace}.svc.cluster.local:5432"
}

output "database_secret_name" {
  description = "Nome do Secret com as credenciais do banco (usado pelo pod do Postgres)"
  value       = kubernetes_secret.db_credentials.metadata[0].name
}

output "monitoring_namespace" {
  description = "Namespace para stack de observabilidade e monitoração"
  value       = "monitoring"
}

output "datadog_config" {
  description = "Configuração sugerida para Datadog no cluster"
  value = {
    site         = var.datadog_site
    cluster_name = var.cluster_name
    env          = "prod"
  }
}

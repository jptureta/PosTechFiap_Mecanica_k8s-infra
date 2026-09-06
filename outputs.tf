output "cluster_name" {
  description = "Nome do cluster AWS EKS criado"
  value       = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  description = "Endpoint da API do Kubernetes (EKS Control Plane)"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Certificado CA para comunicacao segura com o cluster"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "ID do Security Group primario criado para o cluster"
  value       = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

output "node_group_name" {
  description = "Nome do Managed Node Group criado"
  value       = aws_eks_node_group.nodes.node_group_name
}

output "kubeconfig_command" {
  description = "Comando AWS CLI para gerar/atualizar o kubeconfig local"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.eks.name}"
}

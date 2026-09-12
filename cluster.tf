# ─────────────────────────────────────────────────────────────
# Cluster Kubernetes Gerenciado AWS EKS + Managed Node Group
# ─────────────────────────────────────────────────────────────
# Adaptado para AWS Academy Learner Lab: utiliza a IAM Role
# pré-existente (LabRole) em vez de criar roles customizadas,
# pois o ambiente educacional restringe operações de IAM.
# ─────────────────────────────────────────────────────────────

# 1. Cluster AWS EKS (usa LabRole como role do Control Plane)
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.lab_role_arn

  vpc_config {
    subnet_ids              = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  tags = {
    Name = var.cluster_name
  }
}

# 2. EKS Managed Node Group com Escalabilidade (Auto Scaling)
#    Usa a mesma LabRole para os worker nodes (EC2).
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.lab_role_arn
  subnet_ids      = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  instance_types = var.node_instance_types
  capacity_type  = "ON_DEMAND"

  # Configuração de Escalabilidade (Cluster Auto Scaling)
  scaling_config {
    desired_size = var.desired_nodes
    max_size     = var.max_nodes
    min_size     = var.min_nodes
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${var.cluster_name}-node-group"
  }
}

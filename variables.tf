variable "aws_region" {
  description = "Região da AWS para criação do cluster EKS e VPC"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "oficina-mecanica-eks"
}

variable "cluster_version" {
  description = "Versão do Kubernetes para o cluster EKS"
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC do cluster"
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_instance_types" {
  description = "Tipos de instâncias EC2 para os worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "min_nodes" {
  description = "Capacidade mínima de nós no Node Group (Auto Scaling)"
  type        = number
  default     = 2
}

variable "max_nodes" {
  description = "Capacidade máxima de nós no Node Group (Auto Scaling)"
  type        = number
  default     = 5
}

variable "desired_nodes" {
  description = "Capacidade desejada de nós no Node Group"
  type        = number
  default     = 2
}

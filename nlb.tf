# ─────────────────────────────────────────────────────────────
# Network Load Balancer + VPC Link para o API Gateway alcancar
# o EKS. A borda publica e o HTTP API Gateway (repo lambda);
# ele fica fora da VPC e precisa de um "cabo" gerenciado para
# alcancar o NodePort da API dentro do cluster.
#
# Fluxo:
#   Cliente -> API Gateway -> VPC Link -> NLB (porta 80)
#     -> NodePort 30000 (Service api) -> Pods FastAPI
#
# O ARN do listener do NLB e as subnets sao publicados no
# AWS SSM Parameter Store para que o SAM (repo lambda) leia
# sem hard-code na hora de criar o VPC Link.
# ─────────────────────────────────────────────────────────────

# 1. Security Group compartilhado pelo NLB e pelas ENIs do VPC Link.
#    - O API Gateway (fora da VPC) fala com as ENIs do VPC Link,
#      que ficam dentro da VPC com este SG.
#    - As ENIs do VPC Link falam com o NLB, tambem com este SG.
#    - Ambos estao dentro da mesma VPC, entao liberar ingresso
#      pelo CIDR da VPC cobre o trajeto sem expor nada externo.
resource "aws_security_group" "nlb" {
  name        = "${var.cluster_name}-nlb-sg"
  description = "SG compartilhado pelo NLB e pelas ENIs do VPC Link do API Gateway"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    description = "HTTP a partir do VPC Link (mesma VPC)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Saida irrestrita (para alcancar o NodePort dos nos)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-nlb-sg"
  }
}

# 2. NLB interno (nao publico): o unico ponto que fala com ele
#    e o VPC Link do API Gateway, que roda dentro desta VPC.
resource "aws_lb" "api" {
  name               = "${var.cluster_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  security_groups    = [aws_security_group.nlb.id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.cluster_name}-nlb"
  }
}

# 3. Target Group na porta do NodePort da API (30000).
#    Alvo do tipo "instance": o NLB envia trafego para cada no
#    do node group e o kube-proxy roteia ate o Pod da API.
resource "aws_lb_target_group" "api" {
  name        = "${var.cluster_name}-api-tg"
  port        = 30000
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.eks_vpc.id

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = {
    Name = "${var.cluster_name}-api-tg"
  }
}

# 4. Listener HTTP do NLB na porta 80, encaminhando ao Target Group.
resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

# 5. Anexa o Target Group ao Auto Scaling Group do Managed Node Group.
#    Quando o HPA ou o cluster autoscaler adicionar/remover nos, eles
#    entram e saem do Target Group automaticamente.
resource "aws_autoscaling_attachment" "api" {
  autoscaling_group_name = aws_eks_node_group.nodes.resources[0].autoscaling_groups[0].name
  lb_target_group_arn    = aws_lb_target_group.api.arn
}

# 6. Libera trafego do SG do NLB para o NodePort no SG primario dos nos.
#    Sem esta regra o pacote chega no no e e descartado pelo firewall.
resource "aws_security_group_rule" "nodes_ingress_nodeport" {
  type                     = "ingress"
  description              = "Trafego do NLB para o NodePort 30000 da API"
  from_port                = 30000
  to_port                  = 30000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nlb.id
  security_group_id        = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

# ─────────────────────────────────────────────────────────────
# Publicacao no SSM Parameter Store para o SAM (repo lambda)
# consumir sem hard-code.
# ─────────────────────────────────────────────────────────────

resource "aws_ssm_parameter" "nlb_listener_arn" {
  name        = "/oficina/nlb/listener_arn"
  description = "ARN do listener HTTP do NLB - alvo do integration do API Gateway"
  type        = "String"
  value       = aws_lb_listener.api.arn
  overwrite   = true
}

resource "aws_ssm_parameter" "nlb_dns_name" {
  name        = "/oficina/nlb/dns_name"
  description = "DNS interno do NLB - util para diagnostico"
  type        = "String"
  value       = aws_lb.api.dns_name
  overwrite   = true
}

resource "aws_ssm_parameter" "vpc_subnet_ids" {
  name        = "/oficina/vpc/subnet_ids"
  description = "IDs das subnets onde o VPC Link cria suas ENIs"
  type        = "StringList"
  value       = "${aws_subnet.public_1.id},${aws_subnet.public_2.id}"
  overwrite   = true
}

resource "aws_ssm_parameter" "vpc_link_security_group_id" {
  name        = "/oficina/vpc/link_security_group_id"
  description = "SG usado pelas ENIs do VPC Link (mesmo SG do NLB)"
  type        = "String"
  value       = aws_security_group.nlb.id
  overwrite   = true
}

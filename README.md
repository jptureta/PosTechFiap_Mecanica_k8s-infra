# Repositório de Infraestrutura Kubernetes

Este repositório é responsável pela infraestrutura base do ambiente Kubernetes da aplicação Oficina Mecânica.

## Objetivo

- provisionar o cluster Kubernetes
- criar namespace e recursos base do ambiente
- preparar o runtime para a aplicação principal
- permitir deploy automatizado por branch e ambiente

## Stack principal

- Terraform
- AWS
- Kubernetes
- kind
- GitHub Actions

## Recursos provisionados

- cluster Kubernetes local ou cloud
- namespace da aplicação
- secrets e configurações base
- redes e serviços de apoio
- integração com a aplicação principal

## Estrutura do repositório

```text
repo-k8s-infra/
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── README.md
├── cluster.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
├── variables.tf
└── .gitignore
```

## Fluxo recomendado

```text
feature/* -> PR -> homologacao -> deploy automático
feature/* -> PR -> main -> deploy automático em produção
```

## Branches

- `homologacao`
- `main`

## CI/CD

O workflow deste repositório executa:

1. `terraform fmt`
2. `terraform validate`
3. `terraform plan` em pull request
4. `terraform apply` em homologação e produção

## Secrets obrigatórios

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

## Como usar

```bash
cp terraform.tfvars.example terraform.tfvars
# ajustar valores sensíveis
terraform init
terraform plan
terraform apply
```

## Observações

- os arquivos de variável sensível devem permanecer fora do Git
- o deploy em produção exige aprovação e checks obrigatórios
- o cluster e recurso base devem existir antes do rollout da aplicação principal

## Regras de proteção

- commits diretos bloqueados
- merge somente via Pull Request
- status checks obrigatórios
- revisão mínima exigida
- bloqueio de force push
- bloqueio de exclusão da branch

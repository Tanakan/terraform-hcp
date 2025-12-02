# ROSA HCP + ALB OIDC

ROSA HCP クラスターに ALB + Google Workspace OIDC 認証を構築するリポジトリ。

## アーキテクチャ

```
Client → ALB (OIDC認証) → NLB → OpenShift Router → App Pods
              ↓
        Google Workspace
```

## ディレクトリ構成

```
rosa-hcp-terraform/
├── infrastructure/     # Layer 1: Terraform (AWS リソース)
│   └── bootstrap/      # Terraform state backend 用
├── platform/           # Layer 2: ArgoCD (Operators, Controllers)
└── apps/               # Layer 3: ArgoCD (Applications)
```

### infrastructure/

**責務**: AWS インフラストラクチャの管理 (Terraform + Terragrunt)

- VPC, Subnets, NAT Gateway
- ROSA HCP クラスター
- Google Workspace IdP 設定
- ALB Controller 用 IAM ロール

#### 前提条件

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [ROSA CLI](https://docs.openshift.com/rosa/rosa_install_access_delete_clusters/rosa_getting_started_iam/rosa-installing-rosa.html)
- AWS CLI (認証設定済み)

```bash
# macOS
brew install terraform terragrunt
brew install rosa-cli
```

#### 実行手順

```bash
cd infrastructure

# 1. ROSA にログイン
rosa login --use-auth-code

# 2. RHCS トークンを環境変数に設定
export RHCS_TOKEN=$(rosa token)

# 3. Terragrunt で実行 (S3 bucket 名は AWS アカウント ID から自動取得)
terragrunt init
terragrunt plan
terragrunt apply
```

#### 削除

```bash
export RHCS_TOKEN=$(rosa token)
terragrunt destroy
```

### platform/

**責務**: クラスター共通コンポーネント (ArgoCD)

- OpenShift GitOps Operator
- AWS Load Balancer Operator
- 共通 ALB Ingress (OIDC 認証)
- `argocd-app.yaml`: ArgoCD Application 定義

### apps/

**責務**: アプリケーション (ArgoCD)

- 各アプリは通常の Route を作成するだけ
- OIDC 設定不要（ALB で認証済み）
- 各アプリに `argocd-app.yaml` を配置

## デプロイ手順

```bash
# 1. Terraform
cd infrastructure && terraform apply

# 2. OpenShift GitOps インストール
oc apply -f platform/openshift-gitops/subscription.yaml

# 3. ArgoCD で platform デプロイ
oc apply -f platform/argocd-app.yaml

# 4. ALB 作成後、Google OAuth Redirect URI 設定

# 5. ArgoCD で apps デプロイ
oc apply -f apps/test-app/argocd-app.yaml
```

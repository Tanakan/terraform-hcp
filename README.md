# ROSA HCP + Google Workspace OIDC

ROSA HCP クラスターに Google Workspace OIDC 認証を構築するリポジトリ。

## アーキテクチャ

```
User → Route → oauth-proxy → Backend App
         ↓
   Google Workspace OIDC (rhcs_identity_provider)
         ↓
   SubjectAccessReview (RoleBinding で認可)
```

## ディレクトリ構成

```
rosa-hcp-terraform/
├── infrastructure/     # Layer 1: Terraform (AWS リソース)
├── platform/           # Layer 2: ArgoCD (Operators)
└── apps/               # Layer 3: ArgoCD (Applications)
```

各ディレクトリの詳細は、それぞれの README.md を参照してください。

## レイヤー別責務

| レイヤー | ツール | 責務 | 依存先 |
|---------|--------|------|--------|
| `infrastructure/` | Terraform | AWS リソース (VPC, ROSA, IAM, IdP) | なし |
| `platform/` | ArgoCD | Operators (External Secrets Operator) | infrastructure/ |
| `apps/` | ArgoCD | Applications (test-app) | platform/ |

## シークレット管理

| シークレット | 管理場所 | 管理方法 |
|-------------|---------|---------|
| Google OIDC client_secret (IdP用) | Terraform | 環境変数 `TF_VAR_google_client_secret` |
| oauth-proxy シークレット (アプリ用) | AWS Secrets Manager | External Secrets Operator |

**設計方針**: Terraform はクラスター作成時に必要なため、External Secrets Operator には依存しません。

## デプロイ手順

```bash
# 1. Infrastructure (Terraform)
cd infrastructure
rosa login --use-auth-code
export RHCS_TOKEN=$(rosa token)
export TF_VAR_google_client_secret="your-secret"
terraform init && terraform apply

# 2. OpenShift GitOps インストール
oc apply -f platform/openshift-gitops/subscription.yaml

# 3. Platform デプロイ (External Secrets Operator)
oc apply -f platform/argocd-app.yaml

# 4. Apps デプロイ
oc apply -f apps/test-app/argocd-app.yaml
```

## 前提条件

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [ROSA CLI](https://docs.openshift.com/rosa/rosa_install_access_delete_clusters/rosa_getting_started_iam/rosa-installing-rosa.html)
- AWS CLI (認証設定済み)
- Google Cloud Console で OAuth 2.0 クライアント設定済み

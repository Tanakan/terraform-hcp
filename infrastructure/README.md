# infrastructure/

## 責務

**AWS インフラストラクチャの管理（Terraform）**

クラスター作成前に必要なリソースを管理します。platform/ や apps/ には依存しません。

## 管理対象

| ファイル | リソース |
|---------|---------|
| `vpc.tf` | VPC, Subnets, NAT Gateway, Internet Gateway |
| `rosa.tf` | ROSA HCP クラスター, OIDC Provider, Operator IAM Roles |
| `idp.tf` | Google Workspace Identity Provider |

## シークレット管理

| シークレット | 管理方法 | 理由 |
|-------------|---------|------|
| `google_client_secret` | 環境変数 `TF_VAR_google_client_secret` | クラスター作成時に必要なため、External Secrets Operator は使用不可 |

## 実行手順

```bash
cd infrastructure

# ROSA にログイン
rosa login --use-auth-code

# 環境変数設定
export RHCS_TOKEN=$(rosa token)
export TF_VAR_google_client_secret="your-secret"

# 実行
terraform init
terraform plan
terraform apply
```

## 依存関係

```
infrastructure/  →  platform/  →  apps/
     ↓                 ↓            ↓
  AWS リソース      Operators    Applications
  (VPC, ROSA)       (External    (test-app)
                    Secrets
                    Operator)
```

- `infrastructure/` は他のレイヤーに依存しない
- `platform/` は `infrastructure/` 完了後にデプロイ
- `apps/` は `platform/` 完了後にデプロイ

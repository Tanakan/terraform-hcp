# apps/

## 責務

**アプリケーションの管理（ArgoCD）**

個々のアプリケーションをデプロイします。各アプリは独立したディレクトリで管理されます。

## 構成

```
apps/
└── test-app/           # サンプルアプリケーション
    ├── argocd-app.yaml # ArgoCD Application 定義
    ├── kustomization.yaml
    ├── namespace.yaml
    ├── deployment.yaml
    ├── service.yaml
    ├── route.yaml
    ├── oauth-proxy-sa.yaml
    ├── eso-oauth-proxy.yaml
    └── rolebinding.yaml
```

## 認証フロー

Google Workspace OIDC + oauth-proxy による認証を実装しています。

```
User → Route → oauth-proxy → Backend (nginx)
         ↓
   Google Workspace OIDC
         ↓
   SubjectAccessReview (SAR)
         ↓
   RoleBinding で許可されたユーザーのみアクセス可能
```

## シークレット管理

アプリケーション用シークレットは External Secrets Operator で管理します。

| ExternalSecret | AWS Secrets Manager | 用途 |
|---------------|---------------------|------|
| `oauth-proxy-secret` | `rosa/oauth-proxy` | oauth-proxy の client_id, client_secret, cookie_secret |

**注意**: シークレットは Git に保存しません。

## デプロイ手順

```bash
# ArgoCD Application をデプロイ
oc apply -f apps/test-app/argocd-app.yaml
```

## 新規アプリ追加

1. `apps/<app-name>/` ディレクトリを作成
2. 必要なマニフェストを配置
3. `argocd-app.yaml` を作成
4. `oc apply -f apps/<app-name>/argocd-app.yaml`

## 依存関係

- **依存先**: `platform/` (External Secrets Operator, ClusterSecretStore)
- **依存先**: `infrastructure/` (Google Workspace IdP)

# platform/

## 責務

**クラスター共通コンポーネントの管理（ArgoCD）**

アプリケーションが使用する共通の Operator やクラスター全体の設定を管理します。

## 管理対象

| ディレクトリ | コンポーネント | 説明 |
|-------------|---------------|------|
| `openshift-gitops/` | OpenShift GitOps Operator | ArgoCD のインストール |
| `external-secrets-operator/` | External Secrets Operator | AWS Secrets Manager との連携 |

## External Secrets Operator

アプリケーション用シークレットを AWS Secrets Manager から取得します。

```
AWS Secrets Manager  →  ClusterSecretStore  →  ExternalSecret  →  Secret
                              ↑
                        IRSA で認証
                   (infrastructure/ で作成)
```

### 構成ファイル

| ファイル | 説明 |
|---------|------|
| `external-secrets-operator/namespace.yaml` | external-secrets namespace |
| `external-secrets-operator/subscription.yaml` | Operator のインストール |
| `external-secrets-operator/operatorconfig.yaml` | Operator の設定 |
| `external-secrets-operator/serviceaccount.yaml` | IRSA 用 ServiceAccount |
| `external-secrets-operator/cluster-store.yaml` | ClusterSecretStore (AWS Secrets Manager) |

## デプロイ手順

```bash
# 1. OpenShift GitOps をインストール
oc apply -f platform/openshift-gitops/subscription.yaml

# 2. ArgoCD Application をデプロイ
oc apply -f platform/argocd-app.yaml
```

## 依存関係

- **依存先**: `infrastructure/` (IRSA 用 IAM Role)
- **依存元**: `apps/` (External Secrets Operator を使用)

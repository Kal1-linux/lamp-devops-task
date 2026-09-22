# AWS IAM Identity Center (AWS SSO) & OIDC Passwordless Security Architecture

This document outlines the production zero-trust credential architecture implemented to eliminate long-lived IAM access keys (`AKIA...`).

---

## 🔒 Enterprise Zero Long-Lived Credentials Policy

In production environments:
1. **No static access keys (`AKIA...`) are stored on disk or committed to Git.**
2. **Short-lived temporary STS session tokens** are generated dynamically.

---

## 1. Local Developer Authentication via AWS SSO

Developers authenticate using AWS IAM Identity Center (AWS SSO) via OAuth2/OIDC. Short-lived session tokens expire automatically after 1 to 12 hours.

### AWS SSO Setup Command:
```bash
aws configure sso
```

### Configuration Prompts:
- **SSO session name**: `devops-sso`
- **SSO start URL**: `https://my-company.awsapps.com/start`
- **SSO region**: `us-east-1`
- **CLI default client Region**: `us-east-1`

### Daily Developer Login Command:
```bash
aws sso login --profile devops-prod
export AWS_PROFILE=devops-prod
```

---

## 2. CI/CD Passwordless Authentication via AWS IAM OIDC Provider

GitHub Actions and CI/CD pipelines use **OpenID Connect (OIDC)** federated identity mapping to assume AWS IAM roles without secret keys.

### AWS IAM OIDC Role Trust Policy (`GitHubActionsOIDCRole`):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::049341091660:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:your-username/lamp-devops-task:*"
        }
      }
    }
  ]
}
```

---

## 3. Kubernetes Pod Authentication via AWS IRSA (IAM Roles for Service Accounts)

Kubernetes workloads do not use static AWS keys. Instead, pods exchange WebIdentity tokens for temporary IAM session credentials:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: lamp-app-sa
  namespace: lamp
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::049341091660:role/LAMPAppSecretsManagerRole
```

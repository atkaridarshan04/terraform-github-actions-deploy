# 🔐 AWS OIDC Bootstrap Setup (Terraform)

This folder bootstraps the **AWS OpenID Connect (OIDC)** trust configuration that allows **GitHub Actions** workflows to deploy AWS infrastructure **without using long-lived AWS access keys**.


## 📘 Overview

GitHub Actions supports secure authentication to AWS via **OpenID Connect (OIDC)**.  
Instead of storing static AWS credentials in GitHub secrets, your workflows can request **short-lived, automatically rotated credentials** from AWS.

This bootstrap Terraform code performs a **one-time setup** in your AWS account:

1. Creates an **OIDC Provider** for GitHub (`token.actions.githubusercontent.com`).
2. Creates an **IAM Role** trusted by that provider.
3. Attaches the required permissions to the role (e.g. `AdministratorAccess` for testing).
4. Defines strict conditions — only your specific GitHub repository can assume this role.

After this setup:
- All CI/CD pipelines use the OIDC role directly for Terraform, deployments, etc.


## 🔒 Security Notes

* The IAM Role trust policy limits access to only your GitHub repository:

  ```hcl
  "StringLike": {
    "token.actions.githubusercontent.com:sub": "repo:<ORG>/<REPO>:*"
  }
  ```
* You can attach a **custom IAM policy** instead of full admin access once verified.
* Tokens are **short-lived** and **auto-rotated** by AWS STS.

---

🧩 *Once this bootstrap is applied successfully, your GitHub repository becomes a fully trusted OIDC identity in AWS.*


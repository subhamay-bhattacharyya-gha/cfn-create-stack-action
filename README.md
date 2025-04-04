![](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![](https://img.shields.io/github/last-commit/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![](https://img.shields.io/github/release-date/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![](https://img.shields.io/github/repo-size/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![](https://img.shields.io/github/issues/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![](https://img.shields.io/github/languages/top/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![](https://img.shields.io/github/commit-activity/m/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/8e5f94c5d25e83cd2d4e189772a67a07/raw/cfn-create-stack-action.json?)

# 🚀 CloudFormation Create GitHub Action

This GitHub Composite Action automates the creation of an AWS CloudFormation stack and monitors its status in real-time.

## 📋 Description

Creates a CloudFormation Stack in the target AWS environment and waits for its completion status. Ideal for CI/CD workflows triggered via GitHub Actions.

## ✅ Features

- Assumes an IAM role via OIDC
- Generates CloudFormation parameters dynamically
- Monitors stack creation live with event logging
- Supports timeout control

## 🧰 Inputs

| Name                    | Description                                         | Type     | Required | Default                                                             |
|-------------------------|-----------------------------------------------------|----------|----------|---------------------------------------------------------------------|
| `aws-role-arn`          | ARN of the IAM role to assume                       | `string` | ✅       | `arn:aws:iam::637423502513:role/subhamay-github-oidc-role`          |
| `aws-region`            | AWS region for deployment                           | `string` | ✅       | `us-east-1`                                                         |
| `cfn-params-file`       | Path to the CloudFormation parameters JSON file     | `string` | ✅       | `./cfn/params/cfn-parameters.json`                                  |
| `ci-build`              | Indicates if this is a CI pipeline run              | `boolean`| ✅       | `true`                                                              |
| `environment`           | Target environment (e.g., `dev`, `test`, `prod`)    | `string` | ✅       | `devl`                                                              |
| `monitor-timeout-seconds` | Timeout in seconds for stack creation monitoring | `number` | ❌       | `600` (10 minutes)                                                  |

## 📦 Outputs

| Name         | Description                          |
|--------------|--------------------------------------|
| `stack-name` | Name of the created CloudFormation stack |

## 🛠 Usage

```yaml
name: Deploy CloudFormation Stack

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Use CloudFormation Create Action
        uses: your-org/cloudformation-create-action@v1
        with:
          aws-role-arn: arn:aws:iam::637423502513:role/subhamay-github-oidc-role
          aws-region: us-east-1
          cfn-params-file: ./cfn/params/cfn-parameters.json
          ci-build: true
          environment: devl
          monitor-timeout-seconds: 600
```

## License

MIT
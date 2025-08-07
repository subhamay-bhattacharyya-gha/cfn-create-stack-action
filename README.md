# CloudFormation Deployment Action

![Built with Kiro](https://img.shields.io/badge/Built%20with-Kiro-blue?style=flat&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEyIDJMMTMuMDkgOC4yNkwyMCA5TDEzLjA5IDE1Ljc0TDEyIDIyTDEwLjkxIDE1Ljc0TDQgOUwxMC45MSA4LjI2TDEyIDJaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)&nbsp;![GitHub Action](https://img.shields.io/badge/GitHub-Action-blue?logo=github)&nbsp;![Release](https://github.com/subhamay-bhattacharyya-gha/cfn-create-stack-action/actions/workflows/release.yaml/badge.svg)&nbsp;![Commit Activity](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![Bash](https://img.shields.io/badge/Language-Bash-green?logo=gnubash)&nbsp;![CloudFormation](https://img.shields.io/badge/AWS-CloudFormation-orange?logo=amazonaws)&nbsp;![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![File Count](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/0456a5201944f7e604f8c24b011a5780/raw/cfn-create-stack-action.json?)

A reusable GitHub Action that automates the deployment of AWS CloudFormation stacks with parameter support, real-time monitoring, and comprehensive error handling.

## Features

- 🚀 **Easy CloudFormation Deployment**: Deploy stacks with a simple, standardized interface
- 📊 **Real-time Monitoring**: Track deployment progress with live stack event monitoring
- 🔧 **Flexible Parameter Support**: Accepts both simple JSON and CloudFormation native parameter formats
- 🏷️ **Smart Stack Tagging**: Apply tags with automatic value quoting for spaces and special characters
- 🛡️ **Comprehensive Error Handling**: Clear error messages and proper exit codes for CI/CD integration
- 🔐 **Security-First**: Automatic IAM capability handling with secure parameter processing
- ✅ **Template Validation**: Pre-deployment template validation to catch errors early
- 🚫 **No Rollback on Failure**: Disabled rollback allows for easier debugging of failed deployments
- 🔄 **Robust Tag Processing**: Fallback mechanisms ensure tags are processed even with temp file issues
- 📋 **Detailed Output**: Stack outputs and deployment summaries for troubleshooting

---

## Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `stack-name` | Name of the CloudFormation stack to deploy | Yes | — |
| `template-path` | Path to the CloudFormation template file (relative to repository root) | Yes | — |
| `deployment-parameters` | CloudFormation parameters as JSON string (supports multiple formats) | No | `null` |
| `cloudformation-tags` | CloudFormation tags as JSON string (key-value pairs) | No | `null` |

### Parameter Formats

The action supports two JSON parameter formats:

#### Simple Key-Value Format
```json
{
  "Environment": "production",
  "InstanceType": "t3.micro",
  "VpcId": "vpc-12345678"
}
```

#### CloudFormation Native Format
```json
[
  {"ParameterName": "Environment", "ParameterValue": "production"},
  {"ParameterName": "InstanceType", "ParameterValue": "t3.micro"},
  {"ParameterName": "VpcId", "ParameterValue": "vpc-12345678"}
]
```

---

## Prerequisites

### AWS Credentials
The action requires AWS credentials to be configured in your GitHub Actions environment. This can be done through:

- **IAM Roles (Recommended)**: Use `aws-actions/configure-aws-credentials` action
- **Environment Variables**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`
- **GitHub Secrets**: Store credentials securely in repository secrets

### Required Permissions
Your AWS credentials must have the following permissions:
- `cloudformation:*` (for stack operations)
- `sts:GetCallerIdentity` (for credential validation)
- Additional permissions based on resources in your CloudFormation templates

### System Dependencies
The following tools are required and typically pre-installed on GitHub Actions runners:
- AWS CLI v2
- jq (JSON processor)

---

## Usage

### Quick Start

To use this action in your GitHub workflow, follow these steps:

1. **Set up AWS credentials** in your repository (see [Prerequisites](#prerequisites))
2. **Create a CloudFormation template** in your repository
3. **Add the action** to your workflow file

### Basic Workflow Setup

Create a `.github/workflows/deploy.yml` file in your repository:

```yaml
name: Deploy CloudFormation Stack

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    name: Deploy Infrastructure
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      
      - name: Deploy CloudFormation stack
        uses: subhamay-bhattacharyya-gha/cfn-create-stack-action@main
        with:
          stack-name: my-stack
          template-path: cloudformation/template.yaml
```

### Action Inputs

The action accepts the following inputs:

- **`stack-name`** (required): The name for your CloudFormation stack
- **`template-path`** (required): Path to your CloudFormation template file
- **`deployment-parameters`** (optional): Parameters for your template in JSON format
- **`cloudformation-tags`** (optional): Tags for your CloudFormation stack in JSON format

### Parameter Usage

You can pass parameters to your CloudFormation template in two ways:

#### Method 1: Simple JSON Object
```yaml
deployment-parameters: |
  {
    "Environment": "production",
    "InstanceType": "t3.micro"
  }
```

#### Method 2: CloudFormation Native Format
```yaml
deployment-parameters: |
  [
    {"ParameterName": "Environment", "ParameterValue": "production"},
    {"ParameterName": "InstanceType", "ParameterValue": "t3.micro"}
  ]
```

### Tag Usage

You can apply tags to your CloudFormation stack using the `cloudformation-tags` input in two formats:

#### Simple Key-Value Format
```yaml
cloudformation-tags: |
  {
    "Environment": "production",
    "Project": "myapp",
    "Owner": "team-alpha",
    "CostCenter": "engineering"
  }
```

#### CloudFormation Native Format (Recommended)
```yaml
cloudformation-tags: |
  [
    {"Key": "Environment", "Value": "production"},
    {"Key": "Project", "Value": "myapp"},
    {"Key": "Owner", "Value": "team-alpha"},
    {"Key": "CostCenter", "Value": "engineering"}
  ]
```

**Note**: Tag values containing spaces and special characters are automatically quoted for proper AWS CLI handling.

### Common Use Cases

#### 1. Environment-based Deployment
```yaml
- name: Deploy to environment
  uses: subhamay-bhattacharyya-gha/cfn-create-stack-action@main
  with:
    stack-name: myapp-${{ github.ref_name }}
    template-path: infrastructure/main.yaml
    deployment-parameters: |
      {
        "Environment": "${{ github.ref_name }}",
        "InstanceType": "${{ github.ref_name == 'main' && 't3.medium' || 't3.micro' }}"
      }
    cloudformation-tags: |
      {
        "Environment": "${{ github.ref_name }}",
        "Project": "myapp",
        "DeployedBy": "GitHub Actions"
      }
```

#### 2. Using GitHub Secrets
```yaml
- name: Deploy with secrets
  uses: subhamay-bhattacharyya-gha/cfn-create-stack-action@main
  with:
    stack-name: secure-stack
    template-path: templates/secure.yaml
    deployment-parameters: |
      {
        "DatabasePassword": "${{ secrets.DB_PASSWORD }}",
        "ApiKey": "${{ secrets.API_KEY }}"
      }
    cloudformation-tags: |
      {
        "Environment": "production",
        "Security": "high",
        "Owner": "${{ github.actor }}"
      }
```

#### 3. Matrix Deployments
```yaml
strategy:
  matrix:
    environment: [dev, staging, prod]
    
steps:
  - name: Deploy to ${{ matrix.environment }}
    uses: subhamay-bhattacharyya-gha/cfn-create-stack-action@main
    with:
      stack-name: myapp-${{ matrix.environment }}
      template-path: infrastructure/app.yaml
      deployment-parameters: |
        {
          "Environment": "${{ matrix.environment }}"
        }
      cloudformation-tags: |
        {
          "Environment": "${{ matrix.environment }}",
          "Project": "myapp",
          "ManagedBy": "GitHubActions"
        }
```

---

## Usage Examples

### Basic Usage

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]
    paths: ['infrastructure/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
          aws-region: us-east-1

      - name: Deploy CloudFormation Stack
        uses: subhamay-bhattacharyya-gha/cfn-create-stack-action@main
        with:
          stack-name: my-application-stack
          template-path: infrastructure/app-stack.yaml
```

### With Simple Parameters

```yaml
      - name: Deploy with Parameters
        uses: subhamay-bhattacharyya-gha/cfn-create-stack-action@main
        with:
          stack-name: my-app-${{ github.ref_name }}
          template-path: infrastructure/app-stack.yaml
          deployment-parameters: |
            {
              "Environment": "${{ github.ref_name }}",
              "InstanceType": "t3.micro",
              "KeyPairName": "my-keypair"
            }
```

### With CloudFormation Native Parameters

```yaml
      - name: Deploy with CloudFormation Parameters
        uses: subhamay-bhattacharyya-gha/cfn-create-stack-action@main
        with:
          stack-name: my-database-stack
          template-path: infrastructure/database.yaml
          deployment-parameters: |
            [
              {"ParameterName": "DBInstanceClass", "ParameterValue": "db.t3.micro"},
              {"ParameterName": "DBName", "ParameterValue": "myapp"},
              {"ParameterName": "MasterUsername", "ParameterValue": "admin"}
            ]
```

### Multi-Environment Deployment

```yaml
name: Multi-Environment Deployment

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options: ['dev', 'staging', 'prod']

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: ${{ vars.AWS_REGION }}

      - name: Deploy Infrastructure
        uses: subhamay-bhattacharyya-gha/cfn-create-stack-action@main
        with:
          stack-name: myapp-${{ github.event.inputs.environment }}
          template-path: infrastructure/main.yaml
          deployment-parameters: |
            {
              "Environment": "${{ github.event.inputs.environment }}",
              "InstanceType": "${{ vars.INSTANCE_TYPE }}",
              "MinSize": "${{ vars.MIN_SIZE }}",
              "MaxSize": "${{ vars.MAX_SIZE }}"
            }
```

### With Conditional Parameters

```yaml
      - name: Set Parameters Based on Branch
        id: params
        run: |
          if [ "${{ github.ref_name }}" == "main" ]; then
            echo 'parameters={"Environment":"prod","InstanceType":"t3.medium","MinSize":"2"}' >> $GITHUB_OUTPUT
          else
            echo 'parameters={"Environment":"dev","InstanceType":"t3.micro","MinSize":"1"}' >> $GITHUB_OUTPUT
          fi

      - name: Deploy Stack
        uses: subhamay-bhattacharyya-gha/cfn-create-stack-action@main
        with:
          stack-name: myapp-${{ github.ref_name }}
          template-path: infrastructure/app.yaml
          deployment-parameters: ${{ steps.params.outputs.parameters }}
```

### With CloudFormation Tags

```yaml
      - name: Deploy with Tags
        uses: subhamay-bhattacharyya-gha/cfn-create-stack-action@main
        with:
          stack-name: tagged-stack
          template-path: infrastructure/app.yaml
          deployment-parameters: |
            {
              "Environment": "production",
              "InstanceType": "t3.medium"
            }
          cloudformation-tags: |
            {
              "Environment": "production",
              "Project": "web-application",
              "Owner": "platform-team",
              "CostCenter": "engineering",
              "ManagedBy": "GitHub Actions",
              "Repository": "${{ github.repository }}",
              "Branch": "${{ github.ref_name }}",
              "CommitSha": "${{ github.sha }}"
            }
```

---

## Output and Monitoring

### Real-time Monitoring
The action provides real-time monitoring of your CloudFormation deployment:

```
=== CloudFormation Deployment ===
Starting CloudFormation deployment...
Stack Name: my-application-stack
Template: infrastructure/app-stack.yaml
Parameters: 3 parameter(s) configured

Deployment started (PID: 12345)
Monitoring stack events...

|  Timestamp           |  Status              |  Type                    |  LogicalId           |  Reason              |
|----------------------|----------------------|--------------------------|----------------------|----------------------|
|  2024-01-15T10:30:15 |  CREATE_IN_PROGRESS  |  AWS::CloudFormation::Stack |  my-application-stack |  User Initiated      |
|  2024-01-15T10:30:45 |  CREATE_IN_PROGRESS  |  AWS::S3::Bucket        |  MyBucket            |                      |
|  2024-01-15T10:31:15 |  CREATE_COMPLETE     |  AWS::S3::Bucket        |  MyBucket            |                      |
```

### Stack Outputs
After successful deployment, the action displays stack outputs:

```
=== Stack Outputs ===
Stack Outputs:
|  OutputKey          |  OutputValue                    |  Description                    |
|---------------------|---------------------------------|---------------------------------|
|  BucketName         |  my-app-bucket-abc123           |  Name of the created S3 bucket  |
|  BucketArn          |  arn:aws:s3:::my-app-bucket-abc123 |  ARN of the created S3 bucket   |
```

---

## Error Handling and Troubleshooting

### Common Error Scenarios

#### Missing Template File
```
❌ Error: CloudFormation template file not found at path: infrastructure/missing.yaml
Please ensure the template file exists and the path is correct.
```

#### Invalid Parameters
```
❌ Error: deployment-parameters must be valid JSON
Provided parameters: [HIDDEN - 45 characters for security]
JSON validation error: parse error: Expected separator ':' at line 2, column 15
```

#### AWS Permission Issues
```
❌ Error: AWS credentials are not configured or invalid
Please ensure AWS credentials are properly configured for this action.
```

#### Template Validation Failure
```
❌ Error: CloudFormation template validation failed
Template: infrastructure/app.yaml
AWS CLI validation output:
ValidationError: Template format error: Unresolved resource dependencies [MyVPC] in the Resources block of the template
```

### Troubleshooting Guide

#### 1. Template Issues
- **Validation Errors**: Check template syntax and resource dependencies
- **Missing Resources**: Ensure all referenced resources exist or are defined
- **Parameter Mismatches**: Verify parameter names match template definitions

#### 2. Permission Issues
- **AWS Credentials**: Ensure credentials are configured and valid
- **IAM Permissions**: Verify required CloudFormation and resource permissions
- **Cross-Account Access**: Check assume role permissions for cross-account deployments

#### 3. Parameter Problems
- **JSON Format**: Validate JSON syntax using online validators
- **Parameter Names**: Ensure parameter names match template definitions exactly
- **Data Types**: Check parameter values match expected types (string, number, etc.)

#### 4. Stack State Issues
- **Stack Exists**: Use unique stack names or delete existing stacks
- **Update Conflicts**: Some resources may require replacement during updates
- **Rollback States**: Delete failed stacks before retrying

### Exit Codes

The action uses standard exit codes for CI/CD integration:

- **0**: Deployment successful
- **1**: Deployment failed (CloudFormation errors, validation failures)
- **126**: System dependency execution issues
- **127**: Missing system dependencies (AWS CLI, jq)

---

## Security Considerations

### Parameter Security
- Parameter values are never logged in plain text
- Sensitive information is masked in logs as `[HIDDEN_FOR_SECURITY]`
- Temporary parameter files are created in secure runner workspace

### IAM Capabilities
- Automatically includes `CAPABILITY_IAM` and `CAPABILITY_NAMED_IAM`
- No user confirmation required for IAM resource creation
- Follows AWS CloudFormation security best practices

### AWS Credentials
- Action does not store or handle AWS credentials directly
- Relies on pre-configured credentials in runner environment
- Supports all standard AWS credential methods

---

## Advanced Configuration

### Custom AWS CLI Options
The action uses sensible defaults but you can customize behavior by modifying your templates or using stack policies.

### Template Validation
All templates are validated before deployment using `aws cloudformation validate-template`.

### Idempotent Deployments
The action uses `--no-fail-on-empty-changeset` to support idempotent deployments where no changes are detected.

### Rollback Behavior
The action uses `--disable-rollback` flag, which means:
- **On Failure**: Failed stacks remain in a failed state instead of rolling back
- **Debugging**: Easier to troubleshoot issues by examining the failed resources
- **Manual Cleanup**: Failed stacks need to be manually deleted before retrying
- **Faster Failures**: No time spent on rollback operations during failures

### Tag Processing
The action includes robust tag processing with the following features:
- **Automatic Quoting**: Tag values with spaces are automatically quoted for AWS CLI compatibility
- **Format Support**: Accepts both simple key-value objects and CloudFormation native array formats
- **Fallback Mechanism**: Uses direct input if temporary file processing fails
- **Special Character Handling**: Properly escapes quotes and special characters in tag values

---

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup
1. Clone the repository
2. Install dependencies: `npm install`
3. Run tests: `./scripts/run-tests.sh`

### Testing
The action includes comprehensive tests:
- Unit tests for parameter processing
- Integration tests with real CloudFormation templates
- Error scenario testing
- GitHub Actions workflow testing

See [tests/README.md](tests/README.md) for detailed testing information.

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Support

- 📖 [Documentation](https://github.com/your-org/cloudformation-deployment-action/wiki)
- 🐛 [Issue Tracker](https://github.com/your-org/cloudformation-deployment-action/issues)
- 💬 [Discussions](https://github.com/your-org/cloudformation-deployment-action/discussions)
- 📧 [Contact](mailto:support@your-org.com)

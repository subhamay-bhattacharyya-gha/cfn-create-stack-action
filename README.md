# CloudFormation Deployment Action

![Release](https://github.com/subhamay-bhattacharyya-gha/cloudformation-deployment-action/actions/workflows/release.yaml/badge.svg)&nbsp;![Commit Activity](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya-gha/cloudformation-deployment-action)&nbsp;![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya-gha/cloudformation-deployment-action)&nbsp;![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya-gha/cloudformation-deployment-action)&nbsp;![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya-gha/cloudformation-deployment-action)&nbsp;![File Count](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya-gha/cloudformation-deployment-action)&nbsp;![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya-gha/cloudformation-deployment-action)&nbsp;![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya-gha/cloudformation-deployment-action)

A reusable GitHub Action that automates the deployment of AWS CloudFormation stacks with parameter support, real-time monitoring, and comprehensive error handling.

## Features

- 🚀 **Easy CloudFormation Deployment**: Deploy stacks with a simple, standardized interface
- 📊 **Real-time Monitoring**: Track deployment progress with live stack event monitoring
- 🔧 **Flexible Parameter Support**: Accepts both simple JSON and CloudFormation native parameter formats
- 🛡️ **Comprehensive Error Handling**: Clear error messages and proper exit codes for CI/CD integration
- 🔐 **Security-First**: Automatic IAM capability handling with secure parameter processing
- ✅ **Template Validation**: Pre-deployment template validation to catch errors early
- 📋 **Detailed Output**: Stack outputs and deployment summaries for troubleshooting

---

## Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `stack-name` | Name of the CloudFormation stack to deploy | Yes | — |
| `template-path` | Path to the CloudFormation template file (relative to repository root) | Yes | — |
| `deployment-parameters` | CloudFormation parameters as JSON string (supports multiple formats) | No | `null` |

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
        uses: your-org/cloudformation-deployment-action@v1
        with:
          stack-name: my-application-stack
          template-path: infrastructure/app-stack.yaml
```

### With Simple Parameters

```yaml
      - name: Deploy with Parameters
        uses: your-org/cloudformation-deployment-action@v1
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
        uses: your-org/cloudformation-deployment-action@v1
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
        uses: your-org/cloudformation-deployment-action@v1
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
        uses: your-org/cloudformation-deployment-action@v1
        with:
          stack-name: myapp-${{ github.ref_name }}
          template-path: infrastructure/app.yaml
          deployment-parameters: ${{ steps.params.outputs.parameters }}
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

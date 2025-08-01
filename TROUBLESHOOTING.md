# CloudFormation Deployment Action - Troubleshooting Guide

This guide provides detailed troubleshooting information for common issues encountered when using the CloudFormation Deployment Action.

## Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Common Error Scenarios](#common-error-scenarios)
- [AWS-Related Issues](#aws-related-issues)
- [Template Issues](#template-issues)
- [Parameter Problems](#parameter-problems)
- [System Dependencies](#system-dependencies)
- [GitHub Actions Integration](#github-actions-integration)
- [Advanced Troubleshooting](#advanced-troubleshooting)

## Quick Diagnostics

### Check Action Status
First, check the GitHub Actions workflow logs to identify which step failed:

1. Go to your repository's **Actions** tab
2. Click on the failed workflow run
3. Expand the failed step to see detailed error messages
4. Look for error codes and specific error messages

### Common Exit Codes
- **0**: Success
- **1**: General deployment failure (CloudFormation errors, validation failures)
- **126**: System dependency execution issues
- **127**: Missing system dependencies (AWS CLI, jq not found)

## Common Error Scenarios

### 1. Missing Template File

**Error Message:**
```
❌ Error: CloudFormation template file not found at path: infrastructure/app.yaml
Please ensure the template file exists and the path is correct.
```

**Causes:**
- Template file path is incorrect
- Template file doesn't exist in the repository
- File is in a different branch or directory

**Solutions:**
1. **Verify file path**: Check that the path in `template-path` is correct relative to repository root
2. **Check file existence**: Ensure the template file is committed to the repository
3. **Case sensitivity**: Verify file name case matches exactly (especially on Linux runners)
4. **Branch consistency**: Ensure the template exists in the branch being deployed

**Example Fix:**
```yaml
# Wrong
template-path: Infrastructure/App.yaml

# Correct
template-path: infrastructure/app.yaml
```

### 2. Invalid JSON Parameters

**Error Message:**
```
❌ Error: deployment-parameters must be valid JSON
JSON validation error: parse error: Expected separator ':' at line 2, column 15
```

**Causes:**
- Malformed JSON syntax
- Missing quotes around strings
- Trailing commas
- Unescaped special characters

**Solutions:**
1. **Validate JSON**: Use an online JSON validator to check syntax
2. **Check quotes**: Ensure all strings are properly quoted
3. **Remove trailing commas**: JSON doesn't allow trailing commas
4. **Escape special characters**: Use proper escaping for quotes and backslashes

**Example Fix:**
```yaml
# Wrong - trailing comma and unquoted value
deployment-parameters: |
  {
    "Environment": "production",
    "InstanceType": t3.micro,
  }

# Correct
deployment-parameters: |
  {
    "Environment": "production",
    "InstanceType": "t3.micro"
  }
```

### 3. AWS Credentials Not Configured

**Error Message:**
```
❌ Error: AWS credentials are not configured or invalid
Please ensure AWS credentials are properly configured for this action.
```

**Causes:**
- AWS credentials not set up in GitHub Actions
- IAM role assumption failed
- Credentials expired or invalid
- Wrong AWS region configuration

**Solutions:**
1. **Configure AWS credentials action**:
```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
    aws-region: us-east-1
```

2. **Use environment variables**:
```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  AWS_DEFAULT_REGION: us-east-1
```

3. **Verify IAM permissions**: Ensure the role/user has CloudFormation permissions

### 4. Template Validation Failure

**Error Message:**
```
❌ Error: CloudFormation template validation failed
ValidationError: Template format error: Unresolved resource dependencies [MyVPC] in the Resources block
```

**Causes:**
- Invalid CloudFormation syntax
- Missing resource dependencies
- Incorrect resource references
- Invalid parameter types

**Solutions:**
1. **Check resource references**: Ensure all `!Ref` and `!GetAtt` references are valid
2. **Validate dependencies**: Make sure dependent resources are defined
3. **Use CloudFormation linter**: Tools like `cfn-lint` can catch issues early
4. **Test locally**: Validate templates using AWS CLI locally

**Example Fix:**
```yaml
# Wrong - referencing undefined resource
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      SubnetId: !Ref MySubnet  # MySubnet not defined

# Correct - define the referenced resource
Resources:
  MySubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: 10.0.1.0/24
  
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      SubnetId: !Ref MySubnet
```

## AWS-Related Issues

### Permission Denied Errors

**Error Message:**
```
User: arn:aws:sts::123456789012:assumed-role/GitHubActionsRole/GitHubActions is not authorized to perform: cloudformation:CreateStack
```

**Solutions:**
1. **Add CloudFormation permissions**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:*"
      ],
      "Resource": "*"
    }
  ]
}
```

2. **Add resource-specific permissions**: Include permissions for all AWS services used in your templates

3. **Use IAM capability**: Ensure your role can pass IAM roles if your template creates IAM resources

### Stack Already Exists

**Error Message:**
```
AlreadyExistsException: Stack [my-stack] already exists
```

**Solutions:**
1. **Use unique stack names**: Include branch name or timestamp
```yaml
stack-name: myapp-${{ github.ref_name }}-${{ github.run_number }}
```

2. **Delete existing stack**: Remove the stack if it's safe to do so
```bash
aws cloudformation delete-stack --stack-name my-stack
```

3. **Use update instead of create**: The action automatically handles updates

### Resource Limit Exceeded

**Error Message:**
```
LimitExceededException: The maximum number of VPCs has been reached
```

**Solutions:**
1. **Check AWS service limits**: Review your account limits in AWS console
2. **Clean up unused resources**: Delete unnecessary resources
3. **Request limit increase**: Contact AWS support for limit increases
4. **Use existing resources**: Reference existing VPCs/subnets instead of creating new ones

## Template Issues

### Circular Dependencies

**Error Message:**
```
Circular dependency between resources: [ResourceA, ResourceB]
```

**Solutions:**
1. **Review resource dependencies**: Check `DependsOn` attributes
2. **Remove unnecessary dependencies**: CloudFormation can often infer dependencies
3. **Restructure resources**: Break circular references by using parameters or outputs

### Invalid Resource Properties

**Error Message:**
```
ValidationError: Template error: instance type 't3.invalid' does not exist
```

**Solutions:**
1. **Check AWS documentation**: Verify valid values for resource properties
2. **Use parameters**: Make instance types configurable
3. **Validate in different regions**: Some instance types aren't available in all regions

## Parameter Problems

### Parameter Type Mismatch

**Error Message:**
```
ValidationError: Parameter 'InstanceCount' must be a number
```

**Solutions:**
1. **Check parameter types in template**:
```yaml
Parameters:
  InstanceCount:
    Type: Number
    Default: 1
```

2. **Ensure parameter values match types**:
```json
{
  "InstanceCount": "2"  // String that can be converted to number
}
```

### Missing Required Parameters

**Error Message:**
```
ValidationError: Parameters: [KeyPairName] must have values
```

**Solutions:**
1. **Provide all required parameters**:
```json
{
  "KeyPairName": "my-keypair",
  "InstanceType": "t3.micro"
}
```

2. **Add default values in template**:
```yaml
Parameters:
  KeyPairName:
    Type: String
    Default: "default-keypair"
```

## System Dependencies

### AWS CLI Not Found

**Error Message:**
```
❌ Error: AWS CLI is not installed or not available in PATH
```

**Solutions:**
1. **Use standard GitHub runners**: They include AWS CLI by default
2. **Install AWS CLI in custom runners**:
```yaml
- name: Install AWS CLI
  run: |
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
```

### jq Not Found

**Error Message:**
```
❌ Error: jq is not installed or not available in PATH
```

**Solutions:**
1. **Use standard GitHub runners**: They include jq by default
2. **Install jq in custom runners**:
```yaml
- name: Install jq
  run: sudo apt-get update && sudo apt-get install -y jq
```

## GitHub Actions Integration

### Workflow Syntax Errors

**Common Issues:**
- Incorrect YAML indentation
- Missing required fields
- Invalid step references

**Solutions:**
1. **Validate YAML syntax**: Use online YAML validators
2. **Check GitHub Actions documentation**: Verify syntax requirements
3. **Use GitHub's workflow editor**: It provides syntax validation

### Secret Management

**Best Practices:**
1. **Use GitHub Secrets**: Store sensitive values securely
2. **Use environment-specific secrets**: Separate secrets for different environments
3. **Rotate credentials regularly**: Update secrets periodically

## Advanced Troubleshooting

### Enable Debug Logging

Add debug environment variables to get more detailed logs:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

### Stack Event Analysis

When deployments fail, analyze stack events:

```bash
aws cloudformation describe-stack-events --stack-name my-stack \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]'
```

### Template Drift Detection

Check if your stack has drifted from the template:

```bash
aws cloudformation detect-stack-drift --stack-name my-stack
aws cloudformation describe-stack-drift-detection-status --stack-drift-detection-id <detection-id>
```

### CloudFormation Logs

Check CloudTrail logs for detailed API call information:

1. Go to AWS CloudTrail console
2. Look for CloudFormation API calls
3. Check for error details and request parameters

## Getting Help

### Resources
- [AWS CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)

### Support Channels
- 🐛 [Issue Tracker](https://github.com/your-org/cloudformation-deployment-action/issues)
- 💬 [Discussions](https://github.com/your-org/cloudformation-deployment-action/discussions)
- 📖 [Wiki](https://github.com/your-org/cloudformation-deployment-action/wiki)

### Reporting Issues

When reporting issues, please include:
1. Complete error message
2. Workflow YAML configuration
3. CloudFormation template (if relevant)
4. Parameter values (sanitized)
5. AWS region and account information (if relevant)

## Prevention Tips

### Best Practices
1. **Test templates locally**: Validate before committing
2. **Use parameter validation**: Add constraints in templates
3. **Implement proper error handling**: Use try-catch patterns where possible
4. **Monitor resource limits**: Keep track of AWS service limits
5. **Use infrastructure as code tools**: Consider AWS CDK or Terraform for complex scenarios
6. **Implement proper CI/CD**: Use staging environments for testing
7. **Regular security reviews**: Audit IAM permissions and credentials
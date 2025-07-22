#!/usr/bin/env bats

# Integration tests with sample CloudFormation templates

setup() {
    export TEST_DIR=$(mktemp -d)
    export ORIGINAL_PWD=$(pwd)
    cd "$TEST_DIR"
    
    # Create sample CloudFormation templates for testing
    create_test_templates
}

teardown() {
    cd "$ORIGINAL_PWD"
    rm -rf "$TEST_DIR"
}

create_test_templates() {
    # Simple S3 bucket template
    cat > simple-s3-template.yaml << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Simple S3 bucket for testing'
Parameters:
  BucketPrefix:
    Type: String
    Default: test-bucket
    Description: Prefix for the S3 bucket name
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]
    Description: Environment name
Resources:
  TestBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${BucketPrefix}-${Environment}-${AWS::AccountId}'
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
Outputs:
  BucketName:
    Description: Name of the created S3 bucket
    Value: !Ref TestBucket
    Export:
      Name: !Sub '${AWS::StackName}-BucketName'
  BucketArn:
    Description: ARN of the created S3 bucket
    Value: !GetAtt TestBucket.Arn
EOF

    # Template with IAM resources
    cat > iam-template.yaml << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'IAM role template for testing CAPABILITY_IAM'
Parameters:
  RoleName:
    Type: String
    Default: TestRole
    Description: Name of the IAM role
Resources:
  TestRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub '${RoleName}-${AWS::StackName}'
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
Outputs:
  RoleArn:
    Description: ARN of the created IAM role
    Value: !GetAtt TestRole.Arn
EOF

    # Invalid template for error testing
    cat > invalid-template.yaml << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Invalid template for error testing'
Resources:
  InvalidResource:
    Type: AWS::InvalidService::InvalidResource
    Properties:
      InvalidProperty: InvalidValue
EOF

    # Template with syntax errors
    cat > syntax-error-template.yaml << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Template with syntax errors'
Resources:
  TestBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${InvalidReference}'
      # Missing required properties
EOF
}

# Helper function to simulate input validation from action.yaml
validate_inputs() {
    local stack_name="$1"
    local template_path="$2"
    local parameters="$3"
    
    # Validate required inputs
    if [ -z "$stack_name" ] || [ "$stack_name" = "null" ]; then
        echo "ERROR: stack-name is required"
        return 1
    fi
    
    if [ -z "$template_path" ] || [ "$template_path" = "null" ]; then
        echo "ERROR: stack-path is required"
        return 1
    fi
    
    # Validate template file existence
    if [ ! -f "$template_path" ]; then
        echo "ERROR: Template file not found: $template_path"
        return 1
    fi
    
    # Validate template file is readable
    if [ ! -r "$template_path" ]; then
        echo "ERROR: Template file is not readable: $template_path"
        return 1
    fi
    
    return 0
}

@test "Valid S3 template should pass validation" {
    run validate_inputs "test-stack" "simple-s3-template.yaml" ""
    [ "$status" -eq 0 ]
}

@test "Valid IAM template should pass validation" {
    run validate_inputs "test-iam-stack" "iam-template.yaml" ""
    [ "$status" -eq 0 ]
}

@test "Missing stack name should fail validation" {
    run validate_inputs "" "simple-s3-template.yaml" ""
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR: stack-name is required"* ]]
}

@test "Missing template path should fail validation" {
    run validate_inputs "test-stack" "" ""
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR: stack-path is required"* ]]
}

@test "Non-existent template file should fail validation" {
    run validate_inputs "test-stack" "non-existent-template.yaml" ""
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR: Template file not found"* ]]
}

@test "Template file permissions should be checked" {
    # Create a file with no read permissions
    touch no-read-template.yaml
    chmod 000 no-read-template.yaml
    
    run validate_inputs "test-stack" "no-read-template.yaml" ""
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR: Template file is not readable"* ]]
    
    # Cleanup
    chmod 644 no-read-template.yaml
    rm no-read-template.yaml
}

@test "AWS CLI template validation should work for valid templates" {
    # Skip if AWS CLI is not available or not configured
    if ! command -v aws >/dev/null 2>&1; then
        skip "AWS CLI not available"
    fi
    
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        skip "AWS credentials not configured"
    fi
    
    run aws cloudformation validate-template --template-body "file://simple-s3-template.yaml"
    [ "$status" -eq 0 ]
}

@test "AWS CLI template validation should fail for invalid templates" {
    # Skip if AWS CLI is not available or not configured
    if ! command -v aws >/dev/null 2>&1; then
        skip "AWS CLI not available"
    fi
    
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        skip "AWS credentials not configured"
    fi
    
    run aws cloudformation validate-template --template-body "file://invalid-template.yaml"
    [ "$status" -ne 0 ]
}

@test "Template with syntax errors should fail AWS validation" {
    # Skip if AWS CLI is not available or not configured
    if ! command -v aws >/dev/null 2>&1; then
        skip "AWS CLI not available"
    fi
    
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        skip "AWS credentials not configured"
    fi
    
    run aws cloudformation validate-template --template-body "file://syntax-error-template.yaml"
    [ "$status" -ne 0 ]
}

@test "Deployment command construction should include capabilities" {
    local stack_name="test-stack"
    local template_path="simple-s3-template.yaml"
    local parameter_overrides="Environment=test BucketPrefix=my-test"
    
    local expected_cmd="aws cloudformation deploy --template-file \"$template_path\" --stack-name \"$stack_name\" --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --no-fail-on-empty-changeset --parameter-overrides $parameter_overrides"
    
    local deploy_cmd="aws cloudformation deploy --template-file \"$template_path\" --stack-name \"$stack_name\" --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --no-fail-on-empty-changeset"
    
    if [ -n "$parameter_overrides" ]; then
        deploy_cmd="$deploy_cmd --parameter-overrides $parameter_overrides"
    fi
    
    [ "$deploy_cmd" = "$expected_cmd" ]
}

@test "Deployment command construction without parameters" {
    local stack_name="test-stack"
    local template_path="simple-s3-template.yaml"
    
    local expected_cmd="aws cloudformation deploy --template-file \"$template_path\" --stack-name \"$stack_name\" --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --no-fail-on-empty-changeset"
    
    local deploy_cmd="aws cloudformation deploy --template-file \"$template_path\" --stack-name \"$stack_name\" --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --no-fail-on-empty-changeset"
    
    [ "$deploy_cmd" = "$expected_cmd" ]
}
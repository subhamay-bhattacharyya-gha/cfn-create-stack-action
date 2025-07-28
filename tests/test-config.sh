#!/bin/bash

# Test configuration and shared utilities for CloudFormation deployment action tests

# Test environment configuration
export TEST_STACK_PREFIX="cfn-action-test"
export TEST_REGION="us-east-1"
export TEST_TIMEOUT=300  # 5 minutes

# Colors for test output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Test utility functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if AWS CLI is available and configured
check_aws_availability() {
    if ! command -v aws >/dev/null 2>&1; then
        log_warning "AWS CLI not available - AWS-dependent tests will be skipped"
        return 1
    fi
    
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        log_warning "AWS credentials not configured - AWS-dependent tests will be skipped"
        return 1
    fi
    
    return 0
}

# Function to generate unique test stack name
generate_test_stack_name() {
    local test_type="$1"
    local timestamp=$(date +%s)
    local random=$(shuf -i 1000-9999 -n 1)
    echo "${TEST_STACK_PREFIX}-${test_type}-${timestamp}-${random}"
}

# Function to cleanup test stacks
cleanup_test_stack() {
    local stack_name="$1"
    
    if check_aws_availability; then
        log_info "Cleaning up test stack: $stack_name"
        aws cloudformation delete-stack --stack-name "$stack_name" 2>/dev/null || true
        
        # Wait for deletion with timeout
        local timeout=$TEST_TIMEOUT
        local elapsed=0
        
        while [ $elapsed -lt $timeout ]; do
            local status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "DELETE_COMPLETE")
            
            if [ "$status" = "DELETE_COMPLETE" ] || [ "$status" = "None" ]; then
                log_success "Stack $stack_name deleted successfully"
                return 0
            fi
            
            sleep 10
            elapsed=$((elapsed + 10))
        done
        
        log_warning "Stack deletion timeout for $stack_name"
    fi
}

# Function to create test CloudFormation templates
create_test_template() {
    local template_type="$1"
    local output_file="$2"
    
    case "$template_type" in
        "simple-s3")
            cat > "$output_file" << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Simple S3 bucket for testing'
Parameters:
  BucketPrefix:
    Type: String
    Default: test-bucket
  Environment:
    Type: String
    Default: test
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
    Value: !Ref TestBucket
  BucketArn:
    Value: !GetAtt TestBucket.Arn
EOF
            ;;
        "iam-role")
            cat > "$output_file" << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'IAM role for testing CAPABILITY_IAM'
Parameters:
  RoleName:
    Type: String
    Default: TestRole
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
    Value: !GetAtt TestRole.Arn
EOF
            ;;
        "invalid")
            cat > "$output_file" << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Invalid template for error testing'
Resources:
  InvalidResource:
    Type: AWS::NonExistent::Resource
    Properties:
      InvalidProperty: InvalidValue
EOF
            ;;
        "syntax-error")
            cat > "$output_file" << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Template with syntax errors'
Resources:
  TestBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${UndefinedParameter}'
EOF
            ;;
        *)
            log_error "Unknown template type: $template_type"
            return 1
            ;;
    esac
    
    log_success "Created test template: $output_file ($template_type)"
}

# Function to validate test environment
validate_test_environment() {
    log_info "Validating test environment..."
    
    # Check required tools
    local required_tools=("jq" "bats")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log_error "Required tool not found: $tool"
            return 1
        fi
    done
    
    # Check AWS availability (optional)
    if check_aws_availability; then
        log_success "AWS CLI is available and configured"
    fi
    
    log_success "Test environment validation completed"
    return 0
}

# Function to run a single test with timeout
run_test_with_timeout() {
    local test_command="$1"
    local timeout_seconds="${2:-$TEST_TIMEOUT}"
    
    timeout "$timeout_seconds" bash -c "$test_command"
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        log_error "Test timed out after $timeout_seconds seconds"
        return 1
    fi
    
    return $exit_code
}

# Export functions for use in test files
export -f log_info log_success log_warning log_error
export -f check_aws_availability generate_test_stack_name cleanup_test_stack
export -f create_test_template validate_test_environment run_test_with_timeout
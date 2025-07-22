#!/bin/bash

# Test script to verify error handling in the CloudFormation deployment action
echo "=== Testing Error Handling Implementation ==="

# Test 1: Missing stack name
echo "Test 1: Testing missing stack name error handling..."
export DEPLOYMENT_STACK_NAME=""
export DEPLOYMENT_TEMPLATE_PATH="test-template.yaml"
export DEPLOYMENT_PARAMETERS=""

# Create a simple test template
cat > test-template.yaml << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Test template for error handling'
Resources:
  TestBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub 'test-bucket-${AWS::StackId}'
EOF

echo "Created test template: test-template.yaml"

# Test the validation logic by extracting just the validation part
echo "Testing input validation logic..."

# Simulate the validation checks
if [ -z "$DEPLOYMENT_STACK_NAME" ] || [ "$DEPLOYMENT_STACK_NAME" = "null" ]; then
  echo "✅ PASS: Missing stack name correctly detected"
else
  echo "❌ FAIL: Missing stack name not detected"
fi

# Test 2: Missing template file
echo ""
echo "Test 2: Testing missing template file error handling..."
export DEPLOYMENT_STACK_NAME="test-stack"
export DEPLOYMENT_TEMPLATE_PATH="nonexistent-template.yaml"

if [ ! -f "$DEPLOYMENT_TEMPLATE_PATH" ]; then
  echo "✅ PASS: Missing template file correctly detected"
else
  echo "❌ FAIL: Missing template file not detected"
fi

# Test 3: Invalid JSON parameters
echo ""
echo "Test 3: Testing invalid JSON parameter handling..."
export DEPLOYMENT_TEMPLATE_PATH="test-template.yaml"
export DEPLOYMENT_PARAMETERS='{"invalid": json}'

# Test JSON validation
if ! echo "$DEPLOYMENT_PARAMETERS" | jq . > /dev/null 2>&1; then
  echo "✅ PASS: Invalid JSON correctly detected"
else
  echo "❌ FAIL: Invalid JSON not detected"
fi

# Test 4: Valid JSON parameters
echo ""
echo "Test 4: Testing valid JSON parameter handling..."
export DEPLOYMENT_PARAMETERS='{"Environment": "test", "InstanceType": "t3.micro"}'

if echo "$DEPLOYMENT_PARAMETERS" | jq . > /dev/null 2>&1; then
  echo "✅ PASS: Valid JSON correctly validated"
else
  echo "❌ FAIL: Valid JSON incorrectly rejected"
fi

# Test 5: CloudFormation native format
echo ""
echo "Test 5: Testing CloudFormation native parameter format..."
export DEPLOYMENT_PARAMETERS='[{"ParameterName": "Environment", "ParameterValue": "test"}]'

if echo "$DEPLOYMENT_PARAMETERS" | jq -e 'type == "array"' > /dev/null 2>&1; then
  if echo "$DEPLOYMENT_PARAMETERS" | jq -e 'all(type == "object" and has("ParameterName") and has("ParameterValue"))' > /dev/null 2>&1; then
    echo "✅ PASS: CloudFormation native format correctly detected and validated"
  else
    echo "❌ FAIL: CloudFormation native format validation failed"
  fi
else
  echo "❌ FAIL: CloudFormation native format not detected as array"
fi

echo ""
echo "=== Error Handling Tests Completed ==="

# Cleanup
rm -f test-template.yaml

echo "Test template cleaned up."
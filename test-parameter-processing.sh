#!/bin/bash

# Test script for parameter processing logic
echo "=== Testing Parameter Processing Logic ==="

# Function to test parameter processing
test_parameter_processing() {
    local test_name="$1"
    local parameters="$2"
    local expected_result="$3"
    
    echo ""
    echo "--- Test: $test_name ---"
    echo "Input: $parameters"
    
    # Set up environment
    export DEPLOYMENT_PARAMETERS="$parameters"
    
    # Extract the parameter processing logic from action.yaml
    PARAMETER_OVERRIDES=""
    
    if [ -n "$DEPLOYMENT_PARAMETERS" ] && [ "$DEPLOYMENT_PARAMETERS" != "" ] && [ "$DEPLOYMENT_PARAMETERS" != "null" ]; then
        echo "Processing deployment parameters..."
        
        # Validate JSON format
        if ! echo "$DEPLOYMENT_PARAMETERS" | jq . > /dev/null 2>&1; then
            echo "❌ Error: deployment-parameters must be valid JSON"
            return 1
        fi
        
        # Detect parameter format using jq
        # Check if it's an array (CloudFormation native format)
        if echo "$DEPLOYMENT_PARAMETERS" | jq -e 'type == "array"' > /dev/null 2>&1; then
            echo "Detected CloudFormation native parameter format (array)"
            
            # Validate array contains objects with ParameterName and ParameterValue
            if ! echo "$DEPLOYMENT_PARAMETERS" | jq -e 'all(type == "object" and has("ParameterName") and has("ParameterValue"))' > /dev/null 2>&1; then
                echo "❌ Error: CloudFormation parameter array must contain objects with 'ParameterName' and 'ParameterValue' keys"
                return 1
            fi
            
            # Convert CloudFormation native format to parameter overrides
            PARAMETER_OVERRIDES=$(echo "$DEPLOYMENT_PARAMETERS" | jq -r '.[] | "\(.ParameterName)=\(.ParameterValue)"' | tr '\n' ' ' | sed 's/ $//')
            
        # Check if it's an object (simple key-value format)
        elif echo "$DEPLOYMENT_PARAMETERS" | jq -e 'type == "object"' > /dev/null 2>&1; then
            echo "Detected simple key-value parameter format (object)"
            
            # Convert simple key-value format to parameter overrides
            PARAMETER_OVERRIDES=$(echo "$DEPLOYMENT_PARAMETERS" | jq -r 'to_entries[] | "\(.key)=\(.value)"' | tr '\n' ' ' | sed 's/ $//')
            
        else
            echo "❌ Error: deployment-parameters must be either an array of CloudFormation parameter objects or a simple key-value object"
            return 1
        fi
        
        echo "✅ Parameter processing completed successfully"
        echo "Parameter overrides: $PARAMETER_OVERRIDES"
    else
        echo "No parameters provided"
    fi
    
    # Check result
    if [ "$PARAMETER_OVERRIDES" = "$expected_result" ]; then
        echo "✅ Test PASSED"
    else
        echo "❌ Test FAILED"
        echo "Expected: $expected_result"
        echo "Got: $PARAMETER_OVERRIDES"
    fi
}

# Test cases
test_parameter_processing "Empty parameters" "" ""
test_parameter_processing "Null parameters" "null" ""
test_parameter_processing "Simple key-value format" '{"Environment": "production", "InstanceType": "t3.micro"}' "Environment=production InstanceType=t3.micro"
test_parameter_processing "CloudFormation native format" '[{"ParameterName": "Environment", "ParameterValue": "production"}, {"ParameterName": "InstanceType", "ParameterValue": "t3.micro"}]' "Environment=production InstanceType=t3.micro"
test_parameter_processing "Single parameter - simple format" '{"Environment": "staging"}' "Environment=staging"
test_parameter_processing "Single parameter - CloudFormation format" '[{"ParameterName": "Environment", "ParameterValue": "staging"}]' "Environment=staging"

echo ""
echo "=== Testing Error Cases ==="

# Test invalid JSON
echo "--- Test: Invalid JSON ---"
export DEPLOYMENT_PARAMETERS='{"invalid": json}'
if echo "$DEPLOYMENT_PARAMETERS" | jq . > /dev/null 2>&1; then
    echo "❌ Should have failed JSON validation"
else
    echo "✅ Correctly detected invalid JSON"
fi

# Test invalid CloudFormation format
echo "--- Test: Invalid CloudFormation format ---"
export DEPLOYMENT_PARAMETERS='[{"WrongKey": "value"}]'
if echo "$DEPLOYMENT_PARAMETERS" | jq -e 'all(type == "object" and has("ParameterName") and has("ParameterValue"))' > /dev/null 2>&1; then
    echo "❌ Should have failed CloudFormation format validation"
else
    echo "✅ Correctly detected invalid CloudFormation format"
fi

echo ""
echo "=== Parameter Processing Tests Completed ==="
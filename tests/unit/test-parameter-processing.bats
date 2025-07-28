#!/usr/bin/env bats

# Unit tests for parameter processing logic using BATS testing framework

setup() {
    # Create temporary directory for test files
    export TEST_DIR=$(mktemp -d)
    export ORIGINAL_PWD=$(pwd)
    cd "$TEST_DIR"
}

teardown() {
    # Clean up temporary directory
    cd "$ORIGINAL_PWD"
    rm -rf "$TEST_DIR"
}

# Helper function to simulate parameter processing logic from action.yaml
process_parameters() {
    local parameters="$1"
    export DEPLOYMENT_PARAMETERS="$parameters"
    
    PARAMETER_OVERRIDES=""
    
    if [ -n "$DEPLOYMENT_PARAMETERS" ] && [ "$DEPLOYMENT_PARAMETERS" != "" ] && [ "$DEPLOYMENT_PARAMETERS" != "null" ]; then
        # Validate JSON format
        if ! echo "$DEPLOYMENT_PARAMETERS" | jq . > /dev/null 2>&1; then
            echo "ERROR: Invalid JSON"
            return 1
        fi
        
        # Detect parameter format using jq
        if echo "$DEPLOYMENT_PARAMETERS" | jq -e 'type == "array"' > /dev/null 2>&1; then
            # CloudFormation native format
            if ! echo "$DEPLOYMENT_PARAMETERS" | jq -e 'all(type == "object" and has("ParameterName") and has("ParameterValue"))' > /dev/null 2>&1; then
                echo "ERROR: Invalid CloudFormation format"
                return 1
            fi
            
            PARAMETER_OVERRIDES=$(echo "$DEPLOYMENT_PARAMETERS" | jq -r '.[] | "\(.ParameterName)=\(.ParameterValue)"' | tr '\n' ' ' | sed 's/ $//')
            
        elif echo "$DEPLOYMENT_PARAMETERS" | jq -e 'type == "object"' > /dev/null 2>&1; then
            # Simple key-value format
            PARAMETER_OVERRIDES=$(echo "$DEPLOYMENT_PARAMETERS" | jq -r 'to_entries[] | "\(.key)=\(.value)"' | tr '\n' ' ' | sed 's/ $//')
            
        else
            echo "ERROR: Invalid parameter format"
            return 1
        fi
    fi
    
    echo "$PARAMETER_OVERRIDES"
}

@test "Empty parameters should return empty string" {
    result=$(process_parameters "")
    [ "$result" = "" ]
}

@test "Null parameters should return empty string" {
    result=$(process_parameters "null")
    [ "$result" = "" ]
}

@test "Simple key-value format with single parameter" {
    result=$(process_parameters '{"Environment": "production"}')
    [ "$result" = "Environment=production" ]
}

@test "Simple key-value format with multiple parameters" {
    result=$(process_parameters '{"Environment": "production", "InstanceType": "t3.micro"}')
    # Parameters can be in any order, so check both possibilities
    [[ "$result" == "Environment=production InstanceType=t3.micro" ]] || [[ "$result" == "InstanceType=t3.micro Environment=production" ]]
}

@test "CloudFormation native format with single parameter" {
    result=$(process_parameters '[{"ParameterName": "Environment", "ParameterValue": "production"}]')
    [ "$result" = "Environment=production" ]
}

@test "CloudFormation native format with multiple parameters" {
    result=$(process_parameters '[{"ParameterName": "Environment", "ParameterValue": "production"}, {"ParameterName": "InstanceType", "ParameterValue": "t3.micro"}]')
    [ "$result" = "Environment=production InstanceType=t3.micro" ]
}

@test "Invalid JSON should fail" {
    run process_parameters '{"invalid": json}'
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR: Invalid JSON"* ]]
}

@test "Invalid CloudFormation format should fail" {
    run process_parameters '[{"WrongKey": "value"}]'
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR: Invalid CloudFormation format"* ]]
}

@test "Invalid parameter type should fail" {
    run process_parameters '"string_instead_of_object"'
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR: Invalid parameter format"* ]]
}

@test "Parameters with special characters" {
    result=$(process_parameters '{"DatabasePassword": "P@ssw0rd!123", "S3Bucket": "my-bucket-name"}')
    [[ "$result" == *"DatabasePassword=P@ssw0rd!123"* ]]
    [[ "$result" == *"S3Bucket=my-bucket-name"* ]]
}

@test "Parameters with spaces in values" {
    result=$(process_parameters '{"Description": "My Test Stack"}')
    [ "$result" = "Description=My Test Stack" ]
}

@test "Empty CloudFormation array should return empty string" {
    result=$(process_parameters '[]')
    [ "$result" = "" ]
}

@test "Empty simple object should return empty string" {
    result=$(process_parameters '{}')
    [ "$result" = "" ]
}
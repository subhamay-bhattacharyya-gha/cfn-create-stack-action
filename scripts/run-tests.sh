#!/bin/bash

# Test runner script for CloudFormation deployment action
set -e

echo "=== CloudFormation Deployment Action Test Suite ==="
echo "Running comprehensive tests..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test suite
run_test_suite() {
    local test_file="$1"
    local test_name="$2"
    
    echo -e "${YELLOW}Running $test_name...${NC}"
    
    if [ ! -f "$test_file" ]; then
        echo -e "${RED}❌ Test file not found: $test_file${NC}"
        return 1
    fi
    
    # Run BATS test and capture output
    if bats "$test_file"; then
        echo -e "${GREEN}✅ $test_name passed${NC}"
        return 0
    else
        echo -e "${RED}❌ $test_name failed${NC}"
        return 1
    fi
}

# Function to check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check if BATS is installed
    if ! command -v bats >/dev/null 2>&1; then
        echo -e "${RED}❌ BATS testing framework is not installed${NC}"
        echo "Please install BATS: https://github.com/bats-core/bats-core"
        return 1
    fi
    
    # Check if jq is installed
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "${RED}❌ jq is not installed${NC}"
        echo "Please install jq: https://stedolan.github.io/jq/"
        return 1
    fi
    
    # Check if AWS CLI is installed
    if ! command -v aws >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  AWS CLI is not installed - some tests will be skipped${NC}"
    else
        echo -e "${GREEN}✅ AWS CLI is available${NC}"
        
        # Check AWS credentials
        if aws sts get-caller-identity >/dev/null 2>&1; then
            echo -e "${GREEN}✅ AWS credentials are configured${NC}"
        else
            echo -e "${YELLOW}⚠️  AWS credentials not configured - AWS-dependent tests will be skipped${NC}"
        fi
    fi
    
    echo -e "${GREEN}✅ Prerequisites check completed${NC}"
    echo ""
}

# Function to run legacy shell tests
run_legacy_tests() {
    echo -e "${YELLOW}Running legacy shell tests...${NC}"
    
    local legacy_tests=(
        "test-parameter-processing.sh"
        "test-error-handling.sh"
        "test-deployment-logic.sh"
    )
    
    for test_script in "${legacy_tests[@]}"; do
        if [ -f "$test_script" ]; then
            echo "Running $test_script..."
            if bash "$test_script"; then
                echo -e "${GREEN}✅ $test_script passed${NC}"
                PASSED_TESTS=$((PASSED_TESTS + 1))
            else
                echo -e "${RED}❌ $test_script failed${NC}"
                FAILED_TESTS=$((FAILED_TESTS + 1))
            fi
            TOTAL_TESTS=$((TOTAL_TESTS + 1))
            echo ""
        else
            echo -e "${YELLOW}⚠️  Legacy test not found: $test_script${NC}"
        fi
    done
}

# Main test execution
main() {
    # Check prerequisites
    if ! check_prerequisites; then
        exit 1
    fi
    
    # Run BATS test suites
    local test_suites=(
        "tests/unit/test-parameter-processing.bats:Parameter Processing Unit Tests"
        "tests/unit/test-error-scenarios.bats:Error Scenarios Unit Tests"
        "tests/integration/test-cloudformation-templates.bats:CloudFormation Templates Integration Tests"
    )
    
    for test_suite in "${test_suites[@]}"; do
        IFS=':' read -r test_file test_name <<< "$test_suite"
        
        if run_test_suite "$test_file" "$test_name"; then
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        echo ""
    done
    
    # Run legacy shell tests if they exist
    run_legacy_tests
    
    # Print summary
    echo "=== Test Summary ==="
    echo "Total test suites: $TOTAL_TESTS"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}💥 Some tests failed${NC}"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    "unit")
        echo "Running unit tests only..."
        run_test_suite "tests/unit/test-parameter-processing.bats" "Parameter Processing Unit Tests"
        run_test_suite "tests/unit/test-error-scenarios.bats" "Error Scenarios Unit Tests"
        ;;
    "integration")
        echo "Running integration tests only..."
        run_test_suite "tests/integration/test-cloudformation-templates.bats" "CloudFormation Templates Integration Tests"
        ;;
    "legacy")
        echo "Running legacy shell tests only..."
        run_legacy_tests
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [unit|integration|legacy|help]"
        echo ""
        echo "Options:"
        echo "  unit        Run unit tests only"
        echo "  integration Run integration tests only"
        echo "  legacy      Run legacy shell tests only"
        echo "  help        Show this help message"
        echo ""
        echo "If no option is provided, all tests will be run."
        ;;
    *)
        main
        ;;
esac
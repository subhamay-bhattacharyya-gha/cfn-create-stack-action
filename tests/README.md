# CloudFormation Deployment Action Test Suite

![Built with Kiro](https://img.shields.io/badge/Built%20with-Kiro-blue?style=flat&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEyIDJMMTMuMDkgOC4yNkwyMCA5TDEzLjA5IDE1Ljc0TDEyIDIyTDEwLjkxIDE1Ljc0TDQgOUwxMC45MSA4LjI2TDEyIDJaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)&nbsp;![Release](https://github.com/subhamay-bhattacharyya-gha/cfn-create-stack-action/actions/workflows/release.yaml/badge.svg)&nbsp;![Commit Activity](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![File Count](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya-gha/cfn-create-stack-action)&nbsp;![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/a7be6954fc2441b8132fcd181a4340be/raw/cfn-create-stack-action.json?)


This directory contains a comprehensive test suite for the CloudFormation deployment action, covering unit tests, integration tests, and error scenarios.

## Test Structure

```
tests/
├── README.md                           # This file
├── test-config.sh                      # Shared test configuration and utilities
├── unit/                               # Unit tests
│   ├── test-parameter-processing.bats  # Parameter processing logic tests
│   └── test-error-scenarios.bats       # Error handling and edge cases
└── integration/                        # Integration tests
    └── test-cloudformation-templates.bats  # Full CloudFormation template tests
```

## Test Types

### Unit Tests

**Parameter Processing Tests** (`tests/unit/test-parameter-processing.bats`)
- Tests both JSON parameter formats (simple key-value and CloudFormation native)
- Validates parameter conversion logic
- Tests CloudFormation tags processing and validation
- Tests edge cases (empty parameters, special characters, etc.)
- Error handling for invalid JSON and malformed parameters/tags

**Error Scenarios Tests** (`tests/unit/test-error-scenarios.bats`)
- System dependency validation (AWS CLI, jq)
- Input validation (missing stack name, template path)
- Template file validation (existence, readability)
- AWS credentials validation
- Error code handling
- Security parameter handling

### Integration Tests

**CloudFormation Templates Tests** (`tests/integration/test-cloudformation-templates.bats`)
- Tests with real CloudFormation templates
- Template validation using AWS CLI
- Deployment command construction
- IAM capability handling
- Template syntax error detection

## Prerequisites

### Required Tools
- **BATS** (Bash Automated Testing System): Testing framework
- **jq**: JSON processing tool
- **AWS CLI**: For AWS-dependent tests (optional)

### Installation

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y bats jq awscli
```

#### macOS
```bash
brew install bats-core jq awscli
```

#### Manual BATS Installation
```bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

### AWS Configuration (Optional)
For AWS-dependent tests, configure AWS credentials:
```bash
aws configure
# or
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-1
```

## Running Tests

### Run All Tests
```bash
./scripts/run-tests.sh
```

### Run Specific Test Suites
```bash
# Unit tests only
./scripts/run-tests.sh unit

# Integration tests only
./scripts/run-tests.sh integration

# Legacy shell tests only
./scripts/run-tests.sh legacy
```

### Run Individual Test Files
```bash
# Parameter processing tests
bats tests/unit/test-parameter-processing.bats

# Error scenarios tests
bats tests/unit/test-error-scenarios.bats

# Integration tests
bats tests/integration/test-cloudformation-templates.bats
```

### Verbose Output
```bash
bats -t tests/unit/test-parameter-processing.bats
```

## Test Coverage

### Requirements Coverage

The test suite covers all requirements from the specification:

**Requirement 2.5** - Parameter parsing failure handling
- ✅ Invalid JSON detection and error reporting
- ✅ Malformed CloudFormation parameter validation
- ✅ Parameter format detection and conversion

**Requirement 5.3** - Template validation failure handling
- ✅ Missing template file detection
- ✅ Unreadable template file handling
- ✅ AWS CLI template validation integration

**Requirement 5.4** - AWS CLI command failure handling
- ✅ Exit code propagation
- ✅ Error message handling
- ✅ Timeout scenarios

**Requirement 6.4** - Error message clarity and actionability
- ✅ Clear error messages for all failure scenarios
- ✅ Proper exit codes for different error types
- ✅ Security-conscious parameter handling

### Test Scenarios

#### Parameter Processing
- ✅ Empty parameters
- ✅ Null parameters
- ✅ Simple key-value JSON format
- ✅ CloudFormation native array format
- ✅ CloudFormation tags processing
- ✅ Invalid JSON handling
- ✅ Malformed CloudFormation parameters/tags
- ✅ Special characters in parameter values
- ✅ Parameters with spaces
- ✅ Empty arrays and objects

#### Input Validation
- ✅ Missing stack name
- ✅ Missing template path
- ✅ Non-existent template files
- ✅ Unreadable template files
- ✅ Null input handling

#### Template Validation
- ✅ Valid CloudFormation templates
- ✅ Invalid resource types
- ✅ Syntax errors in templates
- ✅ AWS CLI validation integration

#### Error Handling
- ✅ System dependency checks (AWS CLI, jq)
- ✅ AWS credentials validation
- ✅ Proper exit codes for all scenarios
- ✅ Security parameter handling (no sensitive value logging)

#### Integration Scenarios
- ✅ Simple S3 bucket deployment
- ✅ IAM role deployment (CAPABILITY_IAM testing)
- ✅ Multi-parameter templates
- ✅ Templates without parameters
- ✅ Deployment command construction

## GitHub Actions Integration

The test suite is integrated with GitHub Actions through `.github/workflows/test-action.yml`:

### Workflow Jobs

1. **unit-tests**: Runs all unit tests
2. **integration-tests**: Runs integration tests with AWS CLI
3. **test-action-simple**: Tests the action with simple parameters
4. **test-action-cloudformation-format**: Tests CloudFormation native parameters
5. **test-action-no-parameters**: Tests deployment without parameters
6. **test-error-scenarios**: Tests error handling scenarios

### Test Execution

Tests run on:
- Push to `main` and `develop` branches
- Pull requests to `main`
- Manual workflow dispatch

AWS-dependent tests are skipped if credentials are not available.

## Test Configuration

### Environment Variables

The test suite uses several environment variables defined in `tests/test-config.sh`:

- `TEST_STACK_PREFIX`: Prefix for test stack names
- `TEST_REGION`: AWS region for testing
- `TEST_TIMEOUT`: Timeout for test operations

### Utility Functions

Common test utilities are provided:
- `log_info`, `log_success`, `log_warning`, `log_error`: Colored logging
- `check_aws_availability`: AWS CLI and credentials validation
- `generate_test_stack_name`: Unique test stack name generation
- `cleanup_test_stack`: Test stack cleanup
- `create_test_template`: Test template generation
- `validate_test_environment`: Test environment validation

## Troubleshooting

### Common Issues

**BATS not found**
```bash
# Install BATS
sudo apt-get install bats  # Ubuntu/Debian
brew install bats-core     # macOS
```

**jq not found**
```bash
# Install jq
sudo apt-get install jq   # Ubuntu/Debian
brew install jq           # macOS
```

**AWS tests skipped**
- Configure AWS credentials
- Ensure AWS CLI is installed and accessible
- Check AWS permissions for CloudFormation operations

**Test timeouts**
- Increase `TEST_TIMEOUT` in `tests/test-config.sh`
- Check AWS service availability
- Verify network connectivity

### Debug Mode

Run tests with debug output:
```bash
BATS_DEBUG=1 bats tests/unit/test-parameter-processing.bats
```

### Manual Test Execution

For debugging specific scenarios:
```bash
# Source test configuration
source tests/test-config.sh

# Run specific test functions
validate_test_environment
create_test_template "simple-s3" "test-template.yaml"
```

## Contributing

When adding new tests:

1. Follow the existing naming convention
2. Add appropriate test documentation
3. Include both positive and negative test cases
4. Update this README if adding new test categories
5. Ensure tests are idempotent and clean up after themselves
6. Use the shared utilities from `test-config.sh`

### Test Naming Convention

- Test files: `test-<feature>.bats`
- Test functions: `@test "descriptive test name"`
- Helper functions: `helper_function_name()`

### Best Practices

- Use descriptive test names
- Test both success and failure scenarios
- Clean up resources after tests
- Use appropriate assertions
- Skip tests when prerequisites are not met
- Log meaningful messages for debugging
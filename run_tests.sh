#!/bin/bash
# Main test runner script for libphonenumber-bindings
# This always runs tests inside Docker for a consistent environment

set -e

# Default test mode is to run all tests
MODE="all"
TEST_TARGET=""
PYTEST_ARGS=""

# Print help message
function show_help {
    echo "Usage: $0 [options] [test_target]"
    echo ""
    echo "Run tests for libphonenumber-bindings in Docker."
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -m, --mode MODE      Test mode: all, specific, module, or file"
    echo "                       all:      Run all tests (default)"
    echo "                       specific: Run a specific test class or method"
    echo "                       module:   Run all tests in a module"
    echo "                       file:     Run all tests in a file"
    echo "  -v, --verbose        Run tests in verbose mode"
    echo "  -k EXPRESSION        Only run tests that match the given expression"
    echo ""
    echo "Examples:"
    echo "  $0                              # Run all tests"
    echo "  $0 -m specific phonenumbertest.PhoneNumberTest  # Run specific test class"
    echo "  $0 -m module phonenumbertest    # Run all tests in phonenumbertest module"
    echo "  $0 -m file tests/test_phonenumber.py  # Run all tests in a file"
    echo "  $0 -v -k \"country_code\"        # Run tests matching 'country_code' in verbose mode"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -v|--verbose)
            PYTEST_ARGS="$PYTEST_ARGS -v"
            shift
            ;;
        -k)
            PYTEST_ARGS="$PYTEST_ARGS -k \"$2\""
            shift 2
            ;;
        *)
            if [ -z "$TEST_TARGET" ]; then
                TEST_TARGET="$1"
            else
                echo "Error: Multiple test targets specified"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Build Docker container
echo "Building Docker container..."
docker-compose build

# Construct the test command based on mode
case $MODE in
    all)
        echo "Running all tests in Docker container..."
        COMMAND="pip install -e . && python -m pytest tests $PYTEST_ARGS"
        ;;
    specific)
        if [ -z "$TEST_TARGET" ]; then
            echo "Error: No test target specified for specific mode"
            show_help
            exit 1
        fi
        echo "Running specific test $TEST_TARGET in Docker container..."
        COMMAND="pip install -e . && python -m tests.run_test $TEST_TARGET"
        ;;
    module)
        if [ -z "$TEST_TARGET" ]; then
            echo "Error: No module specified for module mode"
            show_help
            exit 1
        fi
        echo "Running all tests in module $TEST_TARGET in Docker container..."
        COMMAND="pip install -e . && python -m pytest tests/$TEST_TARGET.py $PYTEST_ARGS"
        ;;
    file)
        if [ -z "$TEST_TARGET" ]; then
            echo "Error: No file specified for file mode"
            show_help
            exit 1
        fi
        echo "Running all tests in file $TEST_TARGET in Docker container..."
        COMMAND="pip install -e . && python -m pytest $TEST_TARGET $PYTEST_ARGS"
        ;;
    *)
        echo "Error: Invalid mode $MODE"
        show_help
        exit 1
        ;;
esac

# Run the tests in Docker
docker-compose run --rm phonenumber-py bash -c "$COMMAND"
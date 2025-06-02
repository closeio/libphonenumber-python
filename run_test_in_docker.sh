#!/bin/bash
set -e

TEST_NAME=$1

if [ -z "$TEST_NAME" ]; then
    echo "Usage: $0 test_name"
    echo "Example: $0 phonenumbertest.PhoneNumberTest"
    exit 1
fi

echo "Building Docker container..."
docker-compose build

echo "Running test $TEST_NAME in Docker container..."
docker-compose run --rm phonenumber-py bash -c "pip install -e . && python -m tests.run_test $TEST_NAME"
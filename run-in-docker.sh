#!/bin/bash
# Helper script to run commands in Docker for libphonenumber-bindings
set -e

# Print a reminder about running tests if no arguments are provided
if [ $# -eq 0 ]; then
    echo "NOTE: This script is for running arbitrary commands in Docker."
    echo "To run tests, please use the run_tests.sh script instead:"
    echo ""
    echo "    ./run_tests.sh [options] [test_target]"
    echo ""
    echo "Run ./run_tests.sh --help for more information."
    echo ""
    echo "Continuing with default Docker Compose command..."
    docker-compose up
    exit 0
fi

# Build the Docker image if it doesn't exist
docker-compose build

# Run the specified command in the Docker container
docker-compose run --rm phonenumber-py "$@"
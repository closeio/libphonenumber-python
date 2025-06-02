#!/bin/bash
set -e

echo "===== Testing Python bindings for libphonenumber ====="

# Determine if we're running in a Docker container
if [ -f "/.dockerenv" ]; then
    echo "Running in Docker container"
    
    # Make sure the package is installed in development mode
    echo "Installing package in development mode..."
    pip install -e .
else
    echo "Running on host system"
    
    # Check if Docker is available and offer to run in Docker
    if command -v docker > /dev/null && command -v docker-compose > /dev/null; then
        echo "Docker detected. You can also run tests in Docker with:"
        echo "./run-in-docker.sh"
        echo ""
        
        read -p "Run tests in Docker instead? (y/n) " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            exec ./run-in-docker.sh "$@"
        fi
    fi
    
    # Install in dev mode if not already installed
    if ! pip show phonenumber-py > /dev/null 2>&1; then
        echo "Installing package in development mode..."
        pip install -e .
    fi
fi

# Run the tests
if command -v pytest > /dev/null; then
    echo "Running tests with pytest..."
    if [ $# -eq 0 ]; then
        pytest tests -v
    else
        pytest "$@"
    fi
else
    echo "Running tests with unittest..."
    if [ $# -eq 0 ]; then
        python -m unittest discover tests
    else
        python -m unittest "$@"
    fi
fi

echo "===== Tests completed ====="
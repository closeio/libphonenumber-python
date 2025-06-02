#!/bin/bash
set -e

echo "Building Docker container..."
docker-compose build

echo "Running tests in Docker container..."
docker-compose run --rm phonenumber-py bash -c "pip install -e . && python -m pytest tests -v"
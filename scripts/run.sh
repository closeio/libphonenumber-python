#!/bin/bash
# Helper script to run commands in Docker for libphonenumber-bindings
set -e

# Run the specified command in the Docker container
docker-compose run --build --rm phonenumber-py "$@"
#!/bin/bash
set -e

# Build the Docker image if it doesn't exist
docker-compose build

# Run the command specified or the default command if none provided
if [ $# -eq 0 ]; then
    docker-compose up
else
    docker-compose run --rm phonenumber-py "$@"
fi
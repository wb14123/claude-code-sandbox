#!/bin/sh

set -e

docker build -t wb14123/claude-code .
docker push wb14123/claude-code

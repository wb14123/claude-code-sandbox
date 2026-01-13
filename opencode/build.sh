#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

docker build -t wb14123/opencode "$SCRIPT_DIR"
docker push wb14123/opencode

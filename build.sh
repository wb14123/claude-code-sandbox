#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Building all Docker images..."

echo ""
echo "=== Building Base Image ==="
"$SCRIPT_DIR/base-image/build.sh"

echo ""
echo "=== Building Claude Code ==="
"$SCRIPT_DIR/claude-code/build.sh"

echo ""
echo "=== Building Qwen Code ==="
"$SCRIPT_DIR/qwen-code/build.sh"

echo ""
echo "=== Building OpenCode ==="
"$SCRIPT_DIR/opencode/build.sh"

echo ""
echo "All images built and pushed successfully!"

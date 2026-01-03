#!/bin/bash

# Script to check for dependency updates
# Used by GitHub Actions workflow

set -o pipefail

echo "Checking for dependency updates..."

# Initialize variables
UPDATES_FOUND=false
UPDATE_MESSAGE=""
CHECK_FAILED=false
ERROR_MESSAGE=""

# 1. Check Node.js base image version
echo "## Checking Node.js base image..."
CURRENT_NODE_VERSION="25"

# Get available Node.js versions from Docker Hub
NODE_TAGS=$(curl -s "https://registry.hub.docker.com/v2/repositories/library/node/tags?page_size=100&name=bookworm" | \
  jq -r '.results[].name' | \
  grep -E '^[0-9]+-bookworm$' | \
  sed 's/-bookworm$//' | \
  sort -V)

LATEST_NODE_VERSION=$(echo "$NODE_TAGS" | tail -n1)

if [ -z "$LATEST_NODE_VERSION" ]; then
  echo "ERROR: Failed to fetch latest Node.js version from Docker Hub"
  CHECK_FAILED=true
  ERROR_MESSAGE="${ERROR_MESSAGE}Failed to fetch Node.js versions from Docker Hub\n"
else
  echo "Current Node.js version: $CURRENT_NODE_VERSION"
  echo "Latest Node.js version: $LATEST_NODE_VERSION"

  if [ "$LATEST_NODE_VERSION" != "$CURRENT_NODE_VERSION" ]; then
    UPDATES_FOUND=true
    UPDATE_MESSAGE="${UPDATE_MESSAGE}### Node.js Base Image Update Available\n"
    UPDATE_MESSAGE="${UPDATE_MESSAGE}- Current: \`node:${CURRENT_NODE_VERSION}-bookworm\`\n"
    UPDATE_MESSAGE="${UPDATE_MESSAGE}- Latest: \`node:${LATEST_NODE_VERSION}-bookworm\`\n\n"
  fi
fi

# 2. Check Claude Code npm package version
echo "## Checking Claude Code npm package..."
LATEST_CLAUDE_CODE=$(npm view @anthropic-ai/claude-code version 2>&1)

if [ $? -ne 0 ] || [ -z "$LATEST_CLAUDE_CODE" ]; then
  echo "ERROR: Failed to fetch latest Claude Code version from npm"
  CHECK_FAILED=true
  ERROR_MESSAGE="${ERROR_MESSAGE}Failed to fetch Claude Code version from npm\n"
else
  echo "Latest Claude Code version on npm: $LATEST_CLAUDE_CODE"
fi

# 3. Check version in published Docker image
echo "## Checking published Docker image..."

# Pull the published image
if ! docker pull wb14123/claude-code:latest; then
  echo "ERROR: Failed to pull Docker image wb14123/claude-code:latest"
  CHECK_FAILED=true
  ERROR_MESSAGE="${ERROR_MESSAGE}Failed to pull Docker image wb14123/claude-code:latest\n"
else
  # Get the Claude Code version from the published image
  # Format is: "2.0.70 (Claude Code)"
  PUBLISHED_CLAUDE_CODE=$(docker run --rm wb14123/claude-code:latest claude --version 2>&1 | grep -oP '^[0-9.]+' || echo "")

  if [ -z "$PUBLISHED_CLAUDE_CODE" ]; then
    echo "ERROR: Failed to extract Claude Code version from published image"
    echo "Raw output from docker run:"
    docker run --rm wb14123/claude-code:latest claude --version 2>&1
    CHECK_FAILED=true
    ERROR_MESSAGE="${ERROR_MESSAGE}Failed to extract Claude Code version from published Docker image\n"
  else
    echo "Claude Code version in published image: $PUBLISHED_CLAUDE_CODE"

    # Compare versions only if we have both versions
    if [ -n "$LATEST_CLAUDE_CODE" ]; then
      if [ "$PUBLISHED_CLAUDE_CODE" != "$LATEST_CLAUDE_CODE" ]; then
        UPDATES_FOUND=true
        UPDATE_MESSAGE="${UPDATE_MESSAGE}### Claude Code Update Available\n"
        UPDATE_MESSAGE="${UPDATE_MESSAGE}- Published image version: \`$PUBLISHED_CLAUDE_CODE\`\n"
        UPDATE_MESSAGE="${UPDATE_MESSAGE}- Latest npm version: \`$LATEST_CLAUDE_CODE\`\n\n"
      fi
    fi
  fi
fi

# 4. Check Node.js image digest to detect base image updates
echo "## Checking for base image updates (same version)..."
CURRENT_NODE_DIGEST=$(docker pull node:${CURRENT_NODE_VERSION}-bookworm 2>&1 | grep -oP 'Digest: \K[a-z0-9:]+' || echo "")

# Get the Node.js digest from our published image
PUBLISHED_IMAGE_NODE_LAYER=$(docker inspect wb14123/claude-code:latest | jq -r '.[0].RootFS.Layers[0]' || echo "")

if [ -n "$CURRENT_NODE_DIGEST" ]; then
  UPDATE_MESSAGE="${UPDATE_MESSAGE}### Base Image Information\n"
  UPDATE_MESSAGE="${UPDATE_MESSAGE}- Latest \`node:${CURRENT_NODE_VERSION}-bookworm\` digest: \`${CURRENT_NODE_DIGEST}\`\n"
  UPDATE_MESSAGE="${UPDATE_MESSAGE}- Consider rebuilding if this has changed\n\n"
fi

# Check if any checks failed
if [ "$CHECK_FAILED" = true ]; then
  echo "ERROR: One or more dependency checks failed!"
  echo -e "\nErrors encountered:\n$ERROR_MESSAGE"

  # Output to GitHub Actions if GITHUB_OUTPUT is set
  if [ -n "$GITHUB_OUTPUT" ]; then
    echo "check_failed=true" >> "$GITHUB_OUTPUT"
    echo "error_message<<EOF" >> "$GITHUB_OUTPUT"
    echo -e "$ERROR_MESSAGE" >> "$GITHUB_OUTPUT"
    echo "EOF" >> "$GITHUB_OUTPUT"
  fi

  exit 1
fi

# Export results
if [ "$UPDATES_FOUND" = true ]; then
  if [ -n "$GITHUB_OUTPUT" ]; then
    echo "updates_found=true" >> "$GITHUB_OUTPUT"
    echo "update_message<<EOF" >> "$GITHUB_OUTPUT"
    echo -e "$UPDATE_MESSAGE" >> "$GITHUB_OUTPUT"
    echo "EOF" >> "$GITHUB_OUTPUT"
  fi
  echo -e "\n$UPDATE_MESSAGE"
else
  if [ -n "$GITHUB_OUTPUT" ]; then
    echo "updates_found=false" >> "$GITHUB_OUTPUT"
  fi
  echo "No updates found. All dependencies are up to date!"
fi

# Always output version info for logging
if [ -n "$GITHUB_OUTPUT" ]; then
  echo "current_node=${CURRENT_NODE_VERSION:-unknown}" >> "$GITHUB_OUTPUT"
  echo "latest_node=${LATEST_NODE_VERSION:-unknown}" >> "$GITHUB_OUTPUT"
  echo "latest_claude_code=${LATEST_CLAUDE_CODE:-unknown}" >> "$GITHUB_OUTPUT"
  echo "published_claude_code=${PUBLISHED_CLAUDE_CODE:-unknown}" >> "$GITHUB_OUTPUT"
fi

echo ""
echo "Check completed successfully!"
echo "- Current Node.js: ${CURRENT_NODE_VERSION:-unknown}"
echo "- Latest Node.js: ${LATEST_NODE_VERSION:-unknown}"
echo "- Published Claude Code: ${PUBLISHED_CLAUDE_CODE:-unknown}"
echo "- Latest Claude Code: ${LATEST_CLAUDE_CODE:-unknown}"

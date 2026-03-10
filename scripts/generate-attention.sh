#!/bin/bash
# Generate attention metadata for audit
OS_NAME="${GOOS:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
echo '{
  "attention": {
    "os": "'"${OS_NAME}"'",
    "build_id": "'"${GITHUB_RUN_ID:-local}"'",
    "notes": "Build executed with focus on security and consistency",
    "generated_at": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
  }
}'

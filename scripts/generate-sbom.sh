#!/bin/bash
# Generate SBOM (Software Bill of Materials) for the current OS
OS_NAME="${GOOS:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
echo '{
  "sbom": {
    "os": "'"${OS_NAME}"'",
    "dependencies": ["go 1.21", "stdlib"],
    "generated_at": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
  }
}'

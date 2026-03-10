#!/bin/bash
# Generate immutability manifest based on SHA256 hash of the binary
OS_NAME="${GOOS:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
BIN_EXT=""
if [ "$OS_NAME" = "windows" ]; then
  BIN_EXT=".exe"
fi
BIN_PATH="build/${OS_NAME}/bin/app${BIN_EXT}"

if [ -f "$BIN_PATH" ]; then
  HASH=$(sha256sum "$BIN_PATH" 2>/dev/null || shasum -a 256 "$BIN_PATH" 2>/dev/null | awk '{print $1}')
else
  HASH="binary not found"
fi

echo '{
  "immutable": {
    "os": "'"${OS_NAME}"'",
    "binary_path": "'"${BIN_PATH}"'",
    "sha256": "'"${HASH}"'",
    "generated_at": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
  }
}'

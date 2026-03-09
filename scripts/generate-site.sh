#!/usr/bin/env bash
# generate-site.sh — Dynamically generates the GitHub Pages site from CI context
# Called by the deploy job in main.yml
set -euo pipefail

SITE_DIR="${1:-./_site}"
TEMPLATE="./site/index.html"
RUN_NUMBER="${GITHUB_RUN_NUMBER:-0}"
COMMIT_SHA="${GITHUB_SHA:0:7}"
BUILD_TIME="$(date -u '+%Y-%m-%d %H:%M UTC')"

mkdir -p "$SITE_DIR"

# --- Determine build statuses from job outcome env vars ---
resolve_status() {
  local outcome="$1"
  case "$outcome" in
    success) echo "success|Passed" ;;
    failure) echo "fail|Failed" ;;
    *)       echo "pending|Running" ;;
  esac
}

IFS='|' read -r LATEX_STATUS LATEX_STATUS_TEXT <<< "$(resolve_status "${LATEX_OUTCOME:-success}")"
IFS='|' read -r PYTHON_STATUS PYTHON_STATUS_TEXT <<< "$(resolve_status "${PYTHON_OUTCOME:-success}")"
IFS='|' read -r SOLIDITY_STATUS SOLIDITY_STATUS_TEXT <<< "$(resolve_status "${SOLIDITY_OUTCOME:-success}")"
IFS='|' read -r CPP_STATUS CPP_STATUS_TEXT <<< "$(resolve_status "${CPP_OUTCOME:-success}")"

LATEX_DURATION="${LATEX_DURATION:-~2m}"
PYTHON_DURATION="${PYTHON_DURATION:-~2m}"
SOLIDITY_DURATION="${SOLIDITY_DURATION:-~30s}"
CPP_DURATION="${CPP_DURATION:-~5m}"

# --- Generate changelog from recent git commits ---
CHANGELOG_ENTRIES=""
while IFS='|' read -r hash date subject; do
  [ -z "$hash" ] && continue
  CHANGELOG_ENTRIES+="<div class=\"changelog-entry\">"
  CHANGELOG_ENTRIES+="<div class=\"changelog-header\">"
  CHANGELOG_ENTRIES+="<span class=\"changelog-version\">${hash}</span>"
  CHANGELOG_ENTRIES+="<span class=\"changelog-date\">${date}</span>"
  CHANGELOG_ENTRIES+="</div>"
  CHANGELOG_ENTRIES+="<div class=\"changelog-body\">${subject}</div>"
  CHANGELOG_ENTRIES+="</div>"
done < <(git log --pretty=format:'%h|%ad|%s' --date=short -n 15 2>/dev/null || echo "")

if [ -z "$CHANGELOG_ENTRIES" ]; then
  CHANGELOG_ENTRIES='<div class="changelog-entry"><div class="changelog-body">No changelog available.</div></div>'
fi

# --- Populate template ---
sed \
  -e "s|{{RUN_NUMBER}}|${RUN_NUMBER}|g" \
  -e "s|{{COMMIT_SHA}}|${COMMIT_SHA}|g" \
  -e "s|{{BUILD_TIME}}|${BUILD_TIME}|g" \
  -e "s|{{LATEX_STATUS}}|${LATEX_STATUS}|g" \
  -e "s|{{LATEX_STATUS_TEXT}}|${LATEX_STATUS_TEXT}|g" \
  -e "s|{{LATEX_DURATION}}|${LATEX_DURATION}|g" \
  -e "s|{{PYTHON_STATUS}}|${PYTHON_STATUS}|g" \
  -e "s|{{PYTHON_STATUS_TEXT}}|${PYTHON_STATUS_TEXT}|g" \
  -e "s|{{PYTHON_DURATION}}|${PYTHON_DURATION}|g" \
  -e "s|{{SOLIDITY_STATUS}}|${SOLIDITY_STATUS}|g" \
  -e "s|{{SOLIDITY_STATUS_TEXT}}|${SOLIDITY_STATUS_TEXT}|g" \
  -e "s|{{SOLIDITY_DURATION}}|${SOLIDITY_DURATION}|g" \
  -e "s|{{CPP_STATUS}}|${CPP_STATUS}|g" \
  -e "s|{{CPP_STATUS_TEXT}}|${CPP_STATUS_TEXT}|g" \
  -e "s|{{CPP_DURATION}}|${CPP_DURATION}|g" \
  "$TEMPLATE" > "${SITE_DIR}/index.html.tmp"

# Changelog needs special handling (multiline)
python3 -c "
import sys
with open('${SITE_DIR}/index.html.tmp', 'r') as f:
    content = f.read()
changelog = '''${CHANGELOG_ENTRIES}'''
content = content.replace('{{CHANGELOG_ENTRIES}}', changelog)
with open('${SITE_DIR}/index.html', 'w') as f:
    f.write(content)
"
rm -f "${SITE_DIR}/index.html.tmp"

# --- Copy manifesto PDF if available ---
if [ -f "./manifesto.pdf" ]; then
  cp ./manifesto.pdf "${SITE_DIR}/manifesto.pdf"
fi

# --- Copy Solidity ABI if available ---
if [ -d "./solidity-artifacts" ]; then
  cp -r ./solidity-artifacts "${SITE_DIR}/abi"
fi

echo "Site generated at ${SITE_DIR}/"
ls -la "${SITE_DIR}/"

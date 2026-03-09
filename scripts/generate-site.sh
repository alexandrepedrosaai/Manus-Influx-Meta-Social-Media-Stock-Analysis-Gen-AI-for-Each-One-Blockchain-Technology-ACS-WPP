#!/usr/bin/env bash
# generate-site.sh — Dynamically generates the GitHub Pages site from CI context
# Called by the deploy job in main.yml
set -euo pipefail

SITE_DIR="${1:-./_site}"
mkdir -p "$SITE_DIR"

python3 << 'PYEOF'
import os, subprocess, html, datetime

site_dir = os.environ.get("1", os.sys.argv[1] if len(os.sys.argv) > 1 else "./_site")
template_path = "./site/index.html"
run_number = os.environ.get("GITHUB_RUN_NUMBER", "0")
commit_sha_full = os.environ.get("GITHUB_SHA", "0000000")
commit_sha = commit_sha_full[:7]
build_time = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")

# Build statuses
def resolve(outcome):
    if outcome == "success":
        return "success", "Passed"
    elif outcome == "failure":
        return "fail", "Failed"
    else:
        return "pending", "Running"

latex_s, latex_t = resolve(os.environ.get("LATEX_OUTCOME", "success"))
python_s, python_t = resolve(os.environ.get("PYTHON_OUTCOME", "success"))
solidity_s, solidity_t = resolve(os.environ.get("SOLIDITY_OUTCOME", "success"))
cpp_s, cpp_t = resolve(os.environ.get("CPP_OUTCOME", "success"))

# Generate changelog from git log
changelog_html = ""
try:
    result = subprocess.run(
        ["git", "log", "--pretty=format:%h|%ad|%s", "--date=short", "-n", "15"],
        capture_output=True, text=True, timeout=10
    )
    for line in result.stdout.strip().split("\n"):
        if not line.strip():
            continue
        parts = line.split("|", 2)
        if len(parts) < 3:
            continue
        h, d, s = parts
        s = html.escape(s)
        changelog_html += f'''<div class="changelog-entry">
<div class="changelog-header">
<span class="changelog-version">{html.escape(h)}</span>
<span class="changelog-date">{html.escape(d)}</span>
</div>
<div class="changelog-body">{s}</div>
</div>
'''
except Exception:
    pass

if not changelog_html:
    changelog_html = '<div class="changelog-entry"><div class="changelog-body">No changelog available.</div></div>'

# Read template
with open(template_path, "r") as f:
    content = f.read()

# Replace placeholders
replacements = {
    "{{RUN_NUMBER}}": run_number,
    "{{COMMIT_SHA}}": commit_sha,
    "{{BUILD_TIME}}": build_time,
    "{{LATEX_STATUS}}": latex_s,
    "{{LATEX_STATUS_TEXT}}": latex_t,
    "{{LATEX_DURATION}}": os.environ.get("LATEX_DURATION", "~2m"),
    "{{PYTHON_STATUS}}": python_s,
    "{{PYTHON_STATUS_TEXT}}": python_t,
    "{{PYTHON_DURATION}}": os.environ.get("PYTHON_DURATION", "~2m"),
    "{{SOLIDITY_STATUS}}": solidity_s,
    "{{SOLIDITY_STATUS_TEXT}}": solidity_t,
    "{{SOLIDITY_DURATION}}": os.environ.get("SOLIDITY_DURATION", "~30s"),
    "{{CPP_STATUS}}": cpp_s,
    "{{CPP_STATUS_TEXT}}": cpp_t,
    "{{CPP_DURATION}}": os.environ.get("CPP_DURATION", "~2m"),
    "{{CHANGELOG_ENTRIES}}": changelog_html,
}

for placeholder, value in replacements.items():
    content = content.replace(placeholder, value)

# Write output
output_path = os.path.join(site_dir, "index.html")
with open(output_path, "w") as f:
    f.write(content)

print(f"Site generated at {site_dir}/")
PYEOF

# Pass site_dir to Python
python3 -c "
import os, subprocess, html, datetime

site_dir = '$SITE_DIR'
template_path = './site/index.html'
run_number = os.environ.get('GITHUB_RUN_NUMBER', '0')
commit_sha_full = os.environ.get('GITHUB_SHA', '0000000')
commit_sha = commit_sha_full[:7]
build_time = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')

def resolve(outcome):
    if outcome == 'success':
        return 'success', 'Passed'
    elif outcome == 'failure':
        return 'fail', 'Failed'
    else:
        return 'pending', 'Running'

latex_s, latex_t = resolve(os.environ.get('LATEX_OUTCOME', 'success'))
python_s, python_t = resolve(os.environ.get('PYTHON_OUTCOME', 'success'))
solidity_s, solidity_t = resolve(os.environ.get('SOLIDITY_OUTCOME', 'success'))
cpp_s, cpp_t = resolve(os.environ.get('CPP_OUTCOME', 'success'))

changelog_html = ''
try:
    result = subprocess.run(
        ['git', 'log', '--pretty=format:%h|%ad|%s', '--date=short', '-n', '15'],
        capture_output=True, text=True, timeout=10
    )
    for line in result.stdout.strip().split('\n'):
        if not line.strip():
            continue
        parts = line.split('|', 2)
        if len(parts) < 3:
            continue
        h, d, s = parts
        s = html.escape(s)
        changelog_html += '<div class=\"changelog-entry\">'
        changelog_html += '<div class=\"changelog-header\">'
        changelog_html += f'<span class=\"changelog-version\">{html.escape(h)}</span>'
        changelog_html += f'<span class=\"changelog-date\">{html.escape(d)}</span>'
        changelog_html += '</div>'
        changelog_html += f'<div class=\"changelog-body\">{s}</div>'
        changelog_html += '</div>'
except Exception:
    pass

if not changelog_html:
    changelog_html = '<div class=\"changelog-entry\"><div class=\"changelog-body\">No changelog available.</div></div>'

with open(template_path, 'r') as f:
    content = f.read()

replacements = {
    '{{RUN_NUMBER}}': run_number,
    '{{COMMIT_SHA}}': commit_sha,
    '{{BUILD_TIME}}': build_time,
    '{{LATEX_STATUS}}': latex_s,
    '{{LATEX_STATUS_TEXT}}': latex_t,
    '{{LATEX_DURATION}}': os.environ.get('LATEX_DURATION', '~2m'),
    '{{PYTHON_STATUS}}': python_s,
    '{{PYTHON_STATUS_TEXT}}': python_t,
    '{{PYTHON_DURATION}}': os.environ.get('PYTHON_DURATION', '~2m'),
    '{{SOLIDITY_STATUS}}': solidity_s,
    '{{SOLIDITY_STATUS_TEXT}}': solidity_t,
    '{{SOLIDITY_DURATION}}': os.environ.get('SOLIDITY_DURATION', '~30s'),
    '{{CPP_STATUS}}': cpp_s,
    '{{CPP_STATUS_TEXT}}': cpp_t,
    '{{CPP_DURATION}}': os.environ.get('CPP_DURATION', '~2m'),
    '{{CHANGELOG_ENTRIES}}': changelog_html,
}

for placeholder, value in replacements.items():
    content = content.replace(placeholder, value)

output_path = os.path.join(site_dir, 'index.html')
with open(output_path, 'w') as f:
    f.write(content)

print(f'Site generated at {site_dir}/')
"

# Copy manifesto PDF if available
if [ -f "./manifesto.pdf" ]; then
  cp ./manifesto.pdf "${SITE_DIR}/manifesto.pdf"
fi

# Copy Solidity ABI if available
if [ -d "./solidity-artifacts" ]; then
  cp -r ./solidity-artifacts "${SITE_DIR}/abi"
fi

echo "=== Final site contents ==="
ls -la "${SITE_DIR}/"

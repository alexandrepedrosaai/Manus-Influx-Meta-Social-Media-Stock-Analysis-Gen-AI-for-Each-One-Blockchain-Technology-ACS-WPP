#!/usr/bin/env python3
"""
generate_site.py — Dynamically generates the GitHub Pages site from CI context.
Called by the deploy job in main.yml.
"""
import os
import sys
import subprocess
import html
import datetime

def main():
    site_dir = sys.argv[1] if len(sys.argv) > 1 else "./_site"
    template_path = "./site/index.html"

    os.makedirs(site_dir, exist_ok=True)

    run_number = os.environ.get("GITHUB_RUN_NUMBER", "0")
    commit_sha = os.environ.get("GITHUB_SHA", "0000000")[:7]
    build_time = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")

    # Resolve build statuses
    def resolve(outcome):
        if outcome == "success":
            return "success", "Passed"
        elif outcome == "failure":
            return "fail", "Failed"
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
            h, d, s = parts[0], parts[1], parts[2]
            changelog_html += (
                '<div class="changelog-entry">'
                '<div class="changelog-header">'
                f'<span class="changelog-version">{html.escape(h)}</span>'
                f'<span class="changelog-date">{html.escape(d)}</span>'
                '</div>'
                f'<div class="changelog-body">{html.escape(s)}</div>'
                '</div>\n'
            )
    except Exception as e:
        print(f"Warning: Could not generate changelog: {e}", file=sys.stderr)

    if not changelog_html:
        changelog_html = (
            '<div class="changelog-entry">'
            '<div class="changelog-body">No changelog available.</div>'
            '</div>'
        )

    # Read template
    with open(template_path, "r") as f:
        content = f.read()

    # Replace all placeholders
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

    # Write final HTML
    output_path = os.path.join(site_dir, "index.html")
    with open(output_path, "w") as f:
        f.write(content)

    print(f"Site generated successfully at {site_dir}/index.html")

if __name__ == "__main__":
    main()

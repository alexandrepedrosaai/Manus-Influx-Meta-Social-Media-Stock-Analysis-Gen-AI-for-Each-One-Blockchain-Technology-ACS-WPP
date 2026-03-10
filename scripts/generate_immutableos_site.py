#!/usr/bin/env python3
"""
generate_immutableos_site.py — Generates a dynamic GitHub Pages site
for the ImmutableOS Build & Release workflow.
"""
import os
import sys
import json
import subprocess
import html
import datetime

def main():
    site_dir = sys.argv[1] if len(sys.argv) > 1 else "./_site"
    os.makedirs(site_dir, exist_ok=True)

    run_number = os.environ.get("GITHUB_RUN_NUMBER", "0")
    commit_sha = os.environ.get("GITHUB_SHA", "0000000")[:7]
    build_time = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")
    repo_url = "https://github.com/alexandrepedrosaai/Manus-Influx-Meta-Social-Media-Stock-Analysis-Gen-AI-for-Each-One-Blockchain-Technology-ASC-WPP"

    # Build statuses
    def badge(outcome):
        if outcome == "success":
            return '<span class="badge success">PASSED</span>'
        elif outcome == "failure":
            return '<span class="badge fail">FAILED</span>'
        return '<span class="badge pending">PENDING</span>'

    linux_status = badge(os.environ.get("LINUX_OUTCOME", "success"))
    windows_status = badge(os.environ.get("WINDOWS_OUTCOME", "success"))
    macos_status = badge(os.environ.get("MACOS_OUTCOME", "success"))
    release_status = badge(os.environ.get("RELEASE_OUTCOME", "success"))

    # Load artifact manifests if available
    def load_json(path):
        try:
            with open(path) as f:
                return json.load(f)
        except Exception:
            return None

    sbom_linux = load_json("./artifacts/linux-artifacts/sbom-linux.json")
    immutable_linux = load_json("./artifacts/linux-artifacts/immutable-linux.json")

    sha256_linux = "N/A"
    if immutable_linux and "immutable" in immutable_linux:
        sha256_linux = immutable_linux["immutable"].get("sha256", "N/A")

    # Generate changelog
    changelog_html = ""
    try:
        result = subprocess.run(
            ["git", "log", "--pretty=format:%h|%ad|%s", "--date=short", "-n", "10"],
            capture_output=True, text=True, timeout=10
        )
        for line in result.stdout.strip().split("\n"):
            if not line.strip():
                continue
            parts = line.split("|", 2)
            if len(parts) < 3:
                continue
            h, d, s = parts
            changelog_html += (
                f'<div class="changelog-entry">'
                f'<span class="hash">{html.escape(h)}</span>'
                f'<span class="date">{html.escape(d)}</span>'
                f'<span class="msg">{html.escape(s)}</span>'
                f'</div>\n'
            )
    except Exception:
        pass

    if not changelog_html:
        changelog_html = '<div class="changelog-entry"><span class="msg">No changelog available.</span></div>'

    # Generate the full HTML page
    page_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ImmutableOS — Build Dashboard</title>
<style>
  :root {{
    --bg: #0d1117; --surface: #161b22; --border: #30363d;
    --text: #e6edf3; --muted: #8b949e; --accent: #58a6ff;
    --green: #3fb950; --red: #f85149; --yellow: #d29922;
  }}
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
         background: var(--bg); color: var(--text); line-height: 1.6; }}
  .container {{ max-width: 1100px; margin: 0 auto; padding: 2rem; }}

  /* Header */
  .header {{ text-align: center; padding: 3rem 0 2rem; border-bottom: 1px solid var(--border); margin-bottom: 2rem; }}
  .header h1 {{ font-size: 2.5rem; background: linear-gradient(135deg, var(--accent), var(--green)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }}
  .header p {{ color: var(--muted); margin-top: 0.5rem; font-size: 1.1rem; }}
  .meta {{ display: flex; justify-content: center; gap: 2rem; margin-top: 1rem; font-size: 0.9rem; color: var(--muted); }}
  .meta code {{ background: var(--surface); padding: 2px 8px; border-radius: 4px; font-size: 0.85rem; }}

  /* Build Grid */
  h2 {{ font-size: 1.4rem; margin: 2rem 0 1rem; padding-bottom: 0.5rem; border-bottom: 1px solid var(--border); }}
  .build-grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1rem; }}
  .build-card {{ background: var(--surface); border: 1px solid var(--border); border-radius: 8px; padding: 1.2rem; }}
  .build-card .title {{ display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem; }}
  .build-card .title h3 {{ font-size: 1rem; }}
  .build-card .desc {{ color: var(--muted); font-size: 0.85rem; }}
  .build-card .tags {{ margin-top: 0.8rem; display: flex; flex-wrap: wrap; gap: 0.4rem; }}
  .tag {{ background: rgba(88,166,255,0.15); color: var(--accent); padding: 2px 10px; border-radius: 12px; font-size: 0.75rem; }}

  /* Badge */
  .badge {{ padding: 3px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; }}
  .badge.success {{ background: rgba(63,185,80,0.2); color: var(--green); }}
  .badge.fail {{ background: rgba(248,81,73,0.2); color: var(--red); }}
  .badge.pending {{ background: rgba(210,153,34,0.2); color: var(--yellow); }}

  /* Integrity */
  .integrity {{ background: var(--surface); border: 1px solid var(--border); border-radius: 8px; padding: 1.5rem; margin-top: 1rem; }}
  .integrity code {{ word-break: break-all; font-size: 0.85rem; color: var(--green); }}

  /* Artifacts */
  .artifact-list {{ display: grid; gap: 0.8rem; margin-top: 1rem; }}
  .artifact {{ background: var(--surface); border: 1px solid var(--border); border-radius: 8px; padding: 1rem 1.2rem;
               display: flex; justify-content: space-between; align-items: center; }}
  .artifact .name {{ font-weight: 600; }}
  .artifact .detail {{ color: var(--muted); font-size: 0.85rem; }}
  .artifact a {{ color: var(--accent); text-decoration: none; font-size: 0.9rem; }}
  .artifact a:hover {{ text-decoration: underline; }}

  /* Changelog */
  .changelog-entry {{ background: var(--surface); border: 1px solid var(--border); border-radius: 8px; padding: 0.8rem 1.2rem;
                      margin-bottom: 0.5rem; display: flex; gap: 1rem; align-items: baseline; }}
  .changelog-entry .hash {{ color: var(--accent); font-family: monospace; font-size: 0.85rem; min-width: 70px; }}
  .changelog-entry .date {{ color: var(--muted); font-size: 0.85rem; min-width: 90px; }}
  .changelog-entry .msg {{ font-size: 0.9rem; }}

  /* Footer */
  .footer {{ text-align: center; padding: 2rem 0; margin-top: 3rem; border-top: 1px solid var(--border); color: var(--muted); font-size: 0.85rem; }}
  .footer a {{ color: var(--accent); text-decoration: none; }}
</style>
</head>
<body>
<div class="container">

  <div class="header">
    <h1>ImmutableOS</h1>
    <p>Multi-platform Go binary build system with immutability verification and SBOM generation</p>
    <div class="meta">
      <span>Build <strong>{run_number}</strong></span>
      <span>Commit <code>{commit_sha}</code></span>
      <span>Deployed <code>{build_time}</code></span>
    </div>
  </div>

  <h2>Build Status</h2>
  <div class="build-grid">
    <div class="build-card">
      <div class="title"><h3>build-linux</h3>{linux_status}</div>
      <div class="desc">Ubuntu x64 — Go 1.21</div>
      <div class="tags"><span class="tag">Linux</span><span class="tag">amd64</span><span class="tag">Go</span></div>
    </div>
    <div class="build-card">
      <div class="title"><h3>build-windows</h3>{windows_status}</div>
      <div class="desc">Windows x64 — Go 1.21</div>
      <div class="tags"><span class="tag">Windows</span><span class="tag">amd64</span><span class="tag">Go</span></div>
    </div>
    <div class="build-card">
      <div class="title"><h3>build-macos</h3>{macos_status}</div>
      <div class="desc">macOS x64 — Go 1.21</div>
      <div class="tags"><span class="tag">macOS</span><span class="tag">amd64</span><span class="tag">Go</span></div>
    </div>
    <div class="build-card">
      <div class="title"><h3>release</h3>{release_status}</div>
      <div class="desc">GitHub Release with all platform binaries</div>
      <div class="tags"><span class="tag">Release</span><span class="tag">tar.gz</span><span class="tag">Manifests</span></div>
    </div>
  </div>

  <h2>Integrity Verification</h2>
  <div class="integrity">
    <p><strong>Linux Binary SHA256:</strong></p>
    <code>{sha256_linux}</code>
    <p style="margin-top:0.8rem; color: var(--muted); font-size: 0.85rem;">
      Each build generates an immutability manifest with SHA256 hash verification.
      SBOM and attention metadata are included for audit compliance.
    </p>
  </div>

  <h2>Release Artifacts</h2>
  <div class="artifact-list">
    <div class="artifact">
      <div><div class="name">immutableos-linux-{run_number}.tar.gz</div><div class="detail">Linux x64 binary + SBOM + manifests</div></div>
      <a href="{repo_url}/releases/tag/immutableos-v{run_number}">Download</a>
    </div>
    <div class="artifact">
      <div><div class="name">immutableos-windows-{run_number}.tar.gz</div><div class="detail">Windows x64 binary + SBOM + manifests</div></div>
      <a href="{repo_url}/releases/tag/immutableos-v{run_number}">Download</a>
    </div>
    <div class="artifact">
      <div><div class="name">immutableos-macos-{run_number}.tar.gz</div><div class="detail">macOS x64 binary + SBOM + manifests</div></div>
      <a href="{repo_url}/releases/tag/immutableos-v{run_number}">Download</a>
    </div>
  </div>

  <h2>Architecture</h2>
  <div class="build-grid">
    <div class="build-card">
      <div class="title"><h3>Go Binary</h3></div>
      <div class="desc">Cross-compiled with GOOS/GOARCH for Linux, Windows, and macOS</div>
    </div>
    <div class="build-card">
      <div class="title"><h3>SBOM</h3></div>
      <div class="desc">Software Bill of Materials — dependency tracking per platform</div>
    </div>
    <div class="build-card">
      <div class="title"><h3>Attention Metadata</h3></div>
      <div class="desc">Audit trail with build ID, security notes, and timestamps</div>
    </div>
    <div class="build-card">
      <div class="title"><h3>Immutability Manifest</h3></div>
      <div class="desc">SHA256 hash verification ensuring binary integrity</div>
    </div>
  </div>

  <h2>Changelog</h2>
  {changelog_html}

  <div class="footer">
    <p>ImmutableOS — Stickler Protocol</p>
    <p><a href="{repo_url}">GitHub Repository</a> &middot; Alexandre Pedrosa &middot; Executive Interoperability Architect</p>
  </div>

</div>
</body>
</html>"""

    output_path = os.path.join(site_dir, "index.html")
    with open(output_path, "w") as f:
        f.write(page_html)

    print(f"ImmutableOS site generated at {output_path}")

if __name__ == "__main__":
    main()

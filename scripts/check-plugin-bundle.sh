#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "$repo_root/scripts/sync-plugin-skill.sh" --check
python3 -m json.tool "$repo_root/.claude-plugin/plugin.json" >/dev/null
python3 -m json.tool "$repo_root/.claude-plugin/marketplace.json" >/dev/null
python3 -m json.tool "$repo_root/.codex-plugin/plugin.json" >/dev/null
python3 -c 'import json, pathlib, sys; allowed={"Productivity","Creativity","Developer Tools","Business & Operations","Data & Analytics","Communication","Education & Research","Security","Finance","Healthcare","Travel","Entertainment","Other"}; category=json.loads(pathlib.Path(sys.argv[1]).read_text())["interface"]["category"]; assert category in allowed, f"unsupported plugin category: {category}"' "$repo_root/.codex-plugin/plugin.json"

test -f "$repo_root/skills/hinge-profile-optimizer/SKILL.md"
test -f "$repo_root/skills/hinge-profile-optimizer/agents/openai.yaml"
test -f "$repo_root/skills/hinge-profile-optimizer/references/research-findings.md"
test -f "$repo_root/assets/hinge-profile-logo.png"
test -f "$repo_root/PRIVACY.md"
test -f "$repo_root/TERMS.md"

bash "$repo_root/scripts/build-plugin-archive.sh"
archive_version="$(python3 -c 'import json, pathlib, sys; print(json.loads(pathlib.Path(sys.argv[1]).read_text())["version"])' "$repo_root/.codex-plugin/plugin.json")"
archive="$repo_root/dist/hinge-profile-optimizer-$archive_version.zip"
archive_listing="$(unzip -Z1 "$archive")"

grep -Fqx 'hinge-profile-optimizer/.codex-plugin/plugin.json' <<<"$archive_listing"
grep -Fqx 'hinge-profile-optimizer/skills/hinge-profile-optimizer/SKILL.md' <<<"$archive_listing"
grep -Fqx 'hinge-profile-optimizer/skills/hinge-profile-optimizer/references/photo-guidelines.md' <<<"$archive_listing"
grep -Fqx 'hinge-profile-optimizer/assets/hinge-profile-logo.png' <<<"$archive_listing"
grep -Fqx 'hinge-profile-optimizer/PRIVACY.md' <<<"$archive_listing"
grep -Fqx 'hinge-profile-optimizer/TERMS.md' <<<"$archive_listing"

echo "Hinge Profile Optimizer plugin bundle is complete."

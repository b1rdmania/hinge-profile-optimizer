#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest_version="$(python3 -c 'import json, pathlib, sys; print(json.loads(pathlib.Path(sys.argv[1]).read_text())["version"])' "$repo_root/.codex-plugin/plugin.json" 2>/dev/null || true)"
version="${1:-$manifest_version}"
archive="$repo_root/dist/hinge-profile-optimizer-$version.zip"
build_root="$(mktemp -d)"
plugin_root="$build_root/hinge-profile-optimizer"

cleanup() {
  rm -rf "$build_root"
}
trap cleanup EXIT

if [[ -z "$version" ]]; then
  echo "Could not determine the plugin version." >&2
  exit 1
fi

bash "$repo_root/scripts/sync-plugin-skill.sh" --check

mkdir -p "$plugin_root/.claude-plugin" "$plugin_root/.codex-plugin" "$plugin_root/assets" "$repo_root/dist"
cp "$repo_root/.claude-plugin/plugin.json" "$plugin_root/.claude-plugin/plugin.json"
cp "$repo_root/.codex-plugin/plugin.json" "$plugin_root/.codex-plugin/plugin.json"
cp -R "$repo_root/skills" "$plugin_root/skills"
cp "$repo_root/assets/hinge-profile-logo.png" "$plugin_root/assets/hinge-profile-logo.png"
cp "$repo_root/README.md" "$repo_root/PRIVACY.md" "$repo_root/TERMS.md" "$repo_root/LICENSE" "$plugin_root/"

rm -f "$archive"
(cd "$build_root" && zip -qr "$archive" hinge-profile-optimizer)
echo "Built $archive"

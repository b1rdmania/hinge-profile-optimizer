#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
packaged_skill="$repo_root/skills/hinge-profile-optimizer"
reference_files=(
  audit-criteria.md
  copy-principles.md
  discovery-questions.md
  hinge-prompts-current.md
  hinge-settings.md
  photo-guidelines.md
  research-findings.md
)

if [[ "${1:-}" == "--check" ]]; then
  cmp --silent "$repo_root/SKILL.md" "$packaged_skill/SKILL.md"
  cmp --silent "$repo_root/agents/openai.yaml" "$packaged_skill/agents/openai.yaml"
  for file in "${reference_files[@]}"; do
    cmp --silent "$repo_root/references/$file" "$packaged_skill/references/$file"
  done
  echo "Packaged plugin skill matches the repository-root skill."
  exit 0
fi

mkdir -p "$packaged_skill/agents" "$packaged_skill/references"
cp "$repo_root/SKILL.md" "$packaged_skill/SKILL.md"
cp "$repo_root/agents/openai.yaml" "$packaged_skill/agents/openai.yaml"
for file in "${reference_files[@]}"; do
  cp "$repo_root/references/$file" "$packaged_skill/references/$file"
done
echo "Updated skills/hinge-profile-optimizer from the repository-root skill."

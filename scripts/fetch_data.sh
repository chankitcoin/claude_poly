#!/usr/bin/env bash
# Download the full market tick datasets (.jsonl.gz) from the GitHub Release into data/.
#
# Env vars:
#   DATA_REPO  owner/repo that holds the release (required)
#   DATA_TAG   release tag (default: data-v1)
#   GH_TOKEN   needed only if the repo is private
set -euo pipefail

REPO="${DATA_REPO:?set DATA_REPO=owner/repo}"
TAG="${DATA_TAG:-data-v1}"
FILES=(
  market_ticks_20260730_100939.jsonl.gz
  market_ticks_20260806_195236.jsonl.gz
  market_ticks_20260906_110940.jsonl.gz
)

cd "$(dirname "$0")/.."
mkdir -p data

# Download through the API asset URLs: works for public and private repos alike.
auth=()
if [ -n "${GH_TOKEN:-}" ]; then
  auth=(-H "Authorization: Bearer $GH_TOKEN")
fi
release_json="$(curl -fsSL "${auth[@]}" "https://api.github.com/repos/$REPO/releases/tags/$TAG")"

for f in "${FILES[@]}"; do
  if [ -s "data/$f" ]; then
    echo "skip $f (already present)"
    continue
  fi
  echo "downloading $f"
  url="$(printf '%s' "$release_json" | python3 -c "import json,sys; print(next(a['url'] for a in json.load(sys.stdin)['assets'] if a['name']=='$f'))")"
  curl -fL --retry 3 -o "data/$f.part" "${auth[@]}" -H "Accept: application/octet-stream" "$url"
  mv "data/$f.part" "data/$f"
done

ls -lh data

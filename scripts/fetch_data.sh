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

if [ -n "${GH_TOKEN:-}" ]; then
  # Private repo: resolve each asset's API URL, then download it with the token.
  release_json="$(curl -fsSL -H "Authorization: Bearer $GH_TOKEN" \
    "https://api.github.com/repos/$REPO/releases/tags/$TAG")"
fi

for f in "${FILES[@]}"; do
  if [ -s "data/$f" ]; then
    echo "skip $f (already present)"
    continue
  fi
  echo "downloading $f"
  if [ -n "${GH_TOKEN:-}" ]; then
    url="$(printf '%s' "$release_json" | python3 -c "import json,sys; print(next(a['url'] for a in json.load(sys.stdin)['assets'] if a['name']=='$f'))")"
    curl -fL --retry 3 -o "data/$f.part" \
      -H "Authorization: Bearer $GH_TOKEN" -H "Accept: application/octet-stream" "$url"
  else
    curl -fL --retry 3 -o "data/$f.part" \
      "https://github.com/$REPO/releases/download/$TAG/$f"
  fi
  mv "data/$f.part" "data/$f"
done

ls -lh data

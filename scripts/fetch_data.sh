#!/usr/bin/env bash
# Download the full market tick datasets (.jsonl.gz) from the GitHub Release.
#
# Env vars:
#   DATA_REPO  owner/repo that holds the release (default: chankitcoin/claude_poly)
#   DATA_TAG   release tag (default: data-v1)
#   DATA_DIR   where to put the files (default: data/ in the repo)
#   GH_TOKEN   needed only if the repo is private
#
# Also works piped from curl (as the cloud setup script does), as long as DATA_DIR is set.
set -euo pipefail

REPO="${DATA_REPO:-chankitcoin/claude_poly}"
TAG="${DATA_TAG:-data-v1}"
DATA_DIR="${DATA_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/data}"
FILES=(
  market_ticks_20260730_100939.jsonl.gz
  market_ticks_20260806_195236.jsonl.gz
  market_ticks_20260906_110940.jsonl.gz
)

mkdir -p "$DATA_DIR"

# Download through the API asset URLs: works for public and private repos alike.
auth=()
if [ -n "${GH_TOKEN:-}" ]; then
  auth=(-H "Authorization: Bearer $GH_TOKEN")
fi
release_json="$(curl -fsSL "${auth[@]}" "https://api.github.com/repos/$REPO/releases/tags/$TAG")"

for f in "${FILES[@]}"; do
  if [ -s "$DATA_DIR/$f" ]; then
    echo "skip $f (already present)"
    continue
  fi
  echo "downloading $f"
  url="$(printf '%s' "$release_json" | python3 -c "import json,sys; print(next(a['url'] for a in json.load(sys.stdin)['assets'] if a['name']=='$f'))")"
  curl -fL --retry 3 -o "$DATA_DIR/$f.part" "${auth[@]}" -H "Accept: application/octet-stream" "$url"
  mv "$DATA_DIR/$f.part" "$DATA_DIR/$f"
done

ls -lh "$DATA_DIR"

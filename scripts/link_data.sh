#!/usr/bin/env bash
# SessionStart hook: in cloud sessions the setup script downloads the datasets to
# /opt/claude_poly_data; link data/ to it so code can use the same paths everywhere.
# Does nothing locally, where /opt/claude_poly_data doesn't exist.
CLOUD_DATA=/opt/claude_poly_data
REPO_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

if [ -d "$CLOUD_DATA" ] && [ ! -e "$REPO_DIR/data" ]; then
  ln -s "$CLOUD_DATA" "$REPO_DIR/data"
fi
exit 0

#!/usr/bin/env bash
# List recent CircleCI runs for a repo, resolving the CLI's project slug
# automatically for edukita/GitLab repos (org uses UUID-based project
# slugs, not gh/gl name slugs, so `circleci run list` can't infer it).
#
# Usage: circleci-pipeline.sh [repo-path] [--limit N]
#   repo-path defaults to the current directory.

set -euo pipefail

REPO_DIR="."
LIMIT=10

while [[ $# -gt 0 ]]; do
    case "$1" in
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        *)
            REPO_DIR="$1"
            shift
            ;;
    esac
done

cd "$REPO_DIR"

REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")

if [[ -f .circleci/info.yml ]]; then
    circleci run list --limit "$LIMIT"
    exit 0
fi

VCS_URL=$(circleci api "api/v1.1/projects" |
    python3 -c "
import json, sys
for p in json.load(sys.stdin):
    if p.get('reponame') == '$REPO_NAME':
        print(p['vcs_url'])
        break
")

if [[ -z "$VCS_URL" ]]; then
    echo "error: no CircleCI project found for repo '$REPO_NAME'" >&2
    exit 1
fi

# vcs_url looks like //circleci.com/<orgID>/<projectID>
IDS=$(echo "$VCS_URL" | sed -E 's#^//circleci\.com/##')
SLUG="circleci/${IDS}"

circleci project link --project "$SLUG"
circleci run list --limit "$LIMIT"

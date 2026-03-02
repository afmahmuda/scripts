#!/bin/bash
#
# make-workspace.sh - Creates workspace with worktrees, supports custom branches
#
# Usage: make-workspace.sh <jira-ticket> <repo1:branch1> <repo2:branch2> ...
# Example: make-workspace.sh EK-3002 paula-backend:feat/learning-summary-dashboard paula-frontend:feat/learning-summary
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEKITA_DIR="$HOME/codekita"
WORKSPACES_DIR="$CODEKITA_DIR/workspaces"

function log_info() {
    echo "[INFO] $1"
}

function log_error() {
    echo "[ERROR] $1" >&2
}

function usage() {
    echo "Usage: $0 <jira-ticket> <repo1:branch1> <repo2:branch2> ..."
    echo "  jira-ticket: e.g., EK-3002"
    echo "  repoN:branchN: repository with optional branch (e.g., paula-backend:feat/my-branch)"
    echo ""
    echo "Examples:"
    echo "  $0 EK-3002 paula-backend:feat/learning-summary-dashboard paula-frontend:feat/learning-summary"
    echo "  $0 EK-3002 paula-backend: paula-frontend:  # uses default branch"
    echo "  $0 EK-3002 paula-backend  # branch defaults to feat/EK-3002/paula-backend"
    exit 1
}

function main() {
    if [[ $# -lt 2 ]]; then
        usage
    fi

    local jira_ticket="$1"
    shift
    local repos=("$@")

    if [[ -z "$jira_ticket" ]]; then
        log_error "Missing jira-ticket"
        usage
    fi

    local type="feat"
    local feature_folder="$jira_ticket"
    local workspace_path="$WORKSPACES_DIR/$feature_folder"

    if [[ -d "$workspace_path" ]]; then
        log_error "Workspace already exists: $workspace_path"
        log_error "Remove it first if you want to recreate"
        exit 1
    fi

    log_info "=== Creating workspace ==="
    log_info "Jira Ticket: $jira_ticket"
    log_info "Repositories: ${#repos[@]}"
    echo ""

    echo "mkdir -p $WORKSPACES_DIR"
    mkdir -p "$WORKSPACES_DIR"

    echo "mkdir -p $workspace_path"
    mkdir -p "$workspace_path"

    echo "mkdir -p $workspace_path/docs"
    mkdir -p "$workspace_path/docs"

    log_info "Workspace created: $workspace_path"
    echo ""

    local success_count=0
    local fail_count=0

    for repo_spec in "${repos[@]}"; do
        local repo_name="${repo_spec%%:*}"
        local branch_name="${repo_spec#*:}"

        if [[ -z "$repo_name" ]]; then
            log_error "Invalid repo: $repo_spec"
            ((fail_count++))
            continue
        fi

        if [[ "$branch_name" == "$repo_name" ]]; then
            branch_name="$type/$jira_ticket/$repo_name"
        fi

        echo ""
        echo ">>> Processing: $repo_name (branch: $branch_name)"
        echo ""

        if "$SCRIPT_DIR/make-tree.sh" "$type" "$jira_ticket" "$repo_name" "$repo_name" "$jira_ticket" "$branch_name" "$jira_ticket"; then
            ((success_count++))
        else
            ((fail_count++))
            log_error "Failed to create worktree for: $repo_name"
        fi

        echo ""
    done

    echo "============================================"
    echo "           WORKSPACE READY"
    echo "============================================"
    echo ""
    echo "Workspace: $workspace_path"
    echo "Success: $success_count | Failed: $fail_count"
    echo ""
    echo "cd $workspace_path && opencode ."
    echo ""
}

main "$@"

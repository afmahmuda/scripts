#!/bin/bash
#
# make-feature-folder.sh - Creates feature workspace with worktrees for target repos
#
# Usage: make-feature-folder.sh <type> <jira-ticket> <feature-name> <repo1> <repo2> ...
# Example: make-feature-folder.sh feat EK-3018 all-student-in-student-tracker paula-backend paula-frontend
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEKITA_DIR="$HOME/codekita"
WORKSPACES_DIR="$CODEKITA_DIR/workspaces"

VALID_TYPES=("feat" "fix" "script")

function log_info() {
    echo "[INFO] $1"
}

function log_error() {
    echo "[ERROR] $1" >&2
}

function usage() {
    echo "Usage: $0 <type> <jira-ticket> <feature-name> <repo1> <repo2> ..."
    echo "  type: feat | fix | script"
    echo "  jira-ticket: e.g., EK-3018"
    echo "  feature-name: e.g., all-student-in-student-tracker"
    echo "  repoN: repositories to include"
    echo ""
    echo "Example: $0 feat EK-3018 all-student-in-student-tracker paula-backend paula-frontend website_backend"
    exit 1
}

function validate_inputs() {
    local type="$1"
    local jira_ticket="$2"
    local feature_name="$3"
    shift 3
    local repos=("$@")

    if [[ -z "$type" ]] || [[ -z "$jira_ticket" ]] || [[ -z "$feature_name" ]]; then
        log_error "Missing required arguments"
        usage
    fi

    if [[ ${#repos[@]} -eq 0 ]]; then
        log_error "No repositories specified"
        usage
    fi

    if [[ ! " ${VALID_TYPES[@]} " =~ " ${type} " ]]; then
        log_error "Invalid type: $type. Must be one of: ${VALID_TYPES[*]}"
        usage
    fi
}

function main() {
    if [[ $# -lt 4 ]]; then
        usage
    fi

    local type="$1"
    local jira_ticket="$2"
    local feature_name="$3"
    shift 3
    local REPOS=("$@")

    validate_inputs "$type" "$jira_ticket" "$feature_name" "${REPOS[@]}"

    local feature_folder="$type-$jira_ticket-$feature_name"
    local workspace_path="$WORKSPACES_DIR/$feature_folder"

    if [[ -d "$workspace_path" ]]; then
        log_error "Feature folder already exists: $workspace_path"
        log_error "Remove it first if you want to recreate"
        exit 1
    fi

    log_info "=== Creating feature workspace ==="
    log_info "Type: $type"
    log_info "Ticket: $jira_ticket"
    log_info "Feature: $feature_name"
    log_info "Repositories: ${#REPOS[@]}"
    echo ""

    echo "mkdir -p $WORKSPACES_DIR"
    mkdir -p "$WORKSPACES_DIR"

    echo "mkdir -p $workspace_path"
    mkdir -p "$workspace_path"

    echo "mkdir -p $workspace_path/docs"
    mkdir -p "$workspace_path/docs"

    echo "--- Creating docs/plan.md ---"
    cat > "$workspace_path/docs/plan.md" << 'EOF'
# Plan

## Goals
-

## Steps
1.

## Notes

EOF
    echo "Created: $workspace_path/docs/plan.md"

    echo "--- Creating docs/todo.md ---"
    cat > "$workspace_path/docs/todo.md" << 'EOF'
# Todo

## In Progress


## Done

EOF
    echo "Created: $workspace_path/docs/todo.md"

    log_info "Workspace created: $workspace_path"
    echo ""

    local success_count=0
    local fail_count=0

    for repo in "${REPOS[@]}"; do
        echo ""
        echo ">>> Processing: $repo"
        echo ""
        
        if "$SCRIPT_DIR/make-tree.sh" "$type" "$jira_ticket" "$feature_name" "$repo" "$jira_ticket"; then
            ((success_count++))
        else
            ((fail_count++))
            log_error "Failed to create worktree for: $repo"
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

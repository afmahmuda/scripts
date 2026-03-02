#!/bin/bash
#
# make-tree.sh - Creates a git worktree for a single repository
#
# Usage: make-tree.sh <type> <jira-ticket> <feature-name> <repo-name>
# Example: make-tree.sh feat EDU-123 payment-refactor website_backend
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
    echo "Usage: $0 <type> <jira-ticket> <feature-name> <repo-name>"
    echo "  type: feat | fix | script"
    echo "  jira-ticket: e.g., EDU-123"
    echo "  feature-name: e.g., payment-refactor"
    echo "  repo-name: e.g., website_backend"
    exit 1
}

function validate_inputs() {
    local type="$1"
    local jira_ticket="$2"
    local feature_name="$3"
    local repo_name="$4"

    if [[ -z "$type" ]] || [[ -z "$jira_ticket" ]] || [[ -z "$feature_name" ]] || [[ -z "$repo_name" ]]; then
        log_error "Missing required arguments"
        usage
    fi

    if [[ ! " ${VALID_TYPES[@]} " =~ " ${type} " ]]; then
        log_error "Invalid type: $type. Must be one of: ${VALID_TYPES[*]}"
        usage
    fi
}

function detect_default_branch() {
    local repo_path="$1"

    cd "$repo_path"

    if git rev-parse --verify main &>/dev/null; then
        echo "main"
    elif git rev-parse --verify master &>/dev/null; then
        echo "master"
    else
        log_error "Neither main nor master branch exists in $repo_path"
        exit 1
    fi
}

function check_branch_in_other_worktrees() {
    local branch="$1"
    local repo_path="$2"

    cd "$repo_path"

    local current_branch
    current_branch=$(git branch --show-current)
    
    if [[ "$current_branch" == "$branch" ]]; then
        return 0
    fi

    local worktree_list
    worktree_list=$(git worktree list --porcelain 2>/dev/null || echo "")

    if echo "$worktree_list" | grep -q "^branch refs/heads/$branch$"; then
        log_error "Branch '$branch' is already checked out in another worktree"
        exit 1
    fi
}

function checkout_to_default_branch() {
    local repo_path="$1"
    local default_branch="$2"
    
    cd "$repo_path"
    
    local current_branch
    current_branch=$(git branch --show-current)
    
    if [[ "$current_branch" == "$default_branch" ]]; then
        return 0
    fi
    
    echo "git checkout $default_branch"
    git checkout "$default_branch"
}

function copy_untracked_files() {
    local src_repo="$1"
    local worktree_path="$2"

    log_info "Copying all files from $src_repo to $worktree_path"

    cd "$src_repo"

    EXCLUDE_DIRS=("node_modules" "vendor" "dist" "build" ".next" "target" "bin" "pulumi" ".git")

    for item in * .*; do
        if [[ "$item" == "." ]] || [[ "$item" == ".." ]] || [[ "$item" == ".git" ]]; then
            continue
        fi
        
        skip=false
        for exclude in "${EXCLUDE_DIRS[@]}"; do
            if [[ "$item" == "$exclude" ]]; then
                skip=true
                break
            fi
        done
        
        if [[ "$skip" == "false" ]]; then
            cp -r "$item" "$worktree_path/" 2>/dev/null || true
        fi
    done

    log_info "Files copied"
}

function main() {
    local type="$1"
    local jira_ticket="$2"
    local feature_name="$3"
    local repo_name="$4"
    local jira_ticket_suffix="${5:-}"
    local custom_branch="${6:-}"
    local feature_folder_name="${7:-}"

    validate_inputs "$type" "$jira_ticket" "$feature_name" "$repo_name"

    local branch_name="${custom_branch:-$type/$jira_ticket/$feature_name}"
    local feature_folder="${feature_folder_name:-$type-$jira_ticket-$feature_name}"

    local repo_path="$CODEKITA_DIR/$repo_name"
    local worktree_name="${jira_ticket_suffix}_${repo_name}"
    local worktree_path="$WORKSPACES_DIR/$feature_folder/$worktree_name"

    if [[ ! -d "$repo_path/.git" ]]; then
        log_error "Repository does not exist: $repo_path"
        exit 1
    fi

    if [[ -d "$worktree_path" ]]; then
        log_error "Worktree already exists: $worktree_path"
        exit 1
    fi

    cd "$repo_path"
    local default_branch
    default_branch=$(detect_default_branch "$repo_path")
    
    local current_branch
    current_branch=$(git branch --show-current)
    
    if [[ "$current_branch" == "$branch_name" ]]; then
        echo ""
        echo "Currently on feature branch, switching to $default_branch first..."
        checkout_to_default_branch "$repo_path" "$default_branch"
    fi

    check_branch_in_other_worktrees "$branch_name" "$repo_path"

    log_info "=== Creating worktree for $repo_name ==="
    log_info "Branch: $branch_name"
    log_info "Worktree path: $worktree_path"

    log_info "Default branch: $default_branch"

    cd "$repo_path"

    echo ""
    echo "git fetch origin --prune"
    git fetch origin --prune 2>/dev/null || true

    if git rev-parse --verify "$branch_name" &>/dev/null; then
        log_info "Branch exists locally"
    else
        echo ""
        echo "git checkout -b $branch_name origin/$default_branch"
        git checkout -b "$branch_name" "origin/$default_branch" 2>/dev/null || {
            log_error "Failed to create branch"
            exit 1
        }
    fi

    echo ""
    echo "mkdir -p $(dirname "$worktree_path")"
    mkdir -p "$(dirname "$worktree_path")"

    echo "git worktree add $worktree_path $branch_name"
    git worktree add "$worktree_path" "$branch_name"

    copy_untracked_files "$repo_path" "$worktree_path"

    echo ""
    echo "============================================"
    echo "              WORKTREE CREATED"
    echo "============================================"
    echo ""
    echo "Repository: $repo_name"
    echo "Branch: $branch_name"
    echo "Worktree: $worktree_path"
    echo ""
    echo "--- Common commands ---"
    echo "git worktree list"
    echo "git status"
    echo "git branch -d $branch_name"
    echo "git worktree remove $worktree_path"
    echo ""
    echo "cd $worktree_path && opencode ."
    echo ""
}

main "$@"

# Stack Worktree

Automate git worktree setup for multi-repository feature development.

## Purpose

Create isolated feature workspaces across multiple repositories simultaneously, enabling full-stack development with proper branch management.

## Branch Naming Convention

```
<type>/<jira-ticket>/<feature-name>
```

- **type**: `feat` | `fix` | `script`
- **jira-ticket**: e.g., `EDU-123`
- **feature-name**: kebab-case, e.g., `payment-refactor`

Examples:
- `feat/EDU-123/payment-refactor`
- `fix/EDU-455/login-timeout`
- `script/EDU-999/worktree-automation`

## Usage

### Create Feature Workspace (Specific Repos)

```bash
~/scripts/stack-worktree/make-feature-folder.sh feat EK-3018 all-student-in-student-tracker paula-backend paula-frontend website_backend go_garage_client
```

This creates:
```
~/codekita/workspaces/feat-EK-3018-all-student-in-student-tracker/
├── docs/
├── feat-EK-3018-all-student-in-student-tracker.code-workspace
├── paula-backend/    (worktree on feat/EK-3018/all-student-in-student-tracker)
├── paula-frontend/  (worktree on feat/EK-3018/all-student-in-student-tracker)
├── website_backend/ (worktree on feat/EK-3018/all-student-in-student-tracker)
└── go_garage_client/ (worktree on feat/EK-3018/all-student-in-student-tracker)
```

### Create Worktree (Single Repository)

```bash
~/scripts/stack-worktree/make-tree.sh feat EK-3018 all-student-in-student-tracker website_backend
```

## Workflow

1. **Create feature workspace**:
   ```bash
   ~/scripts/stack-worktree/make-feature-folder.sh feat EDU-123 payment-refactor
   ```

2. **Open OpenCode**:
   ```bash
   cd ~/codekita/workspaces/feat-EDU-123-payment-refactor
   opencode .
   ```

3. **Work on your feature** across all repositories

4. **Cleanup** when done:
   ```bash
   cd ~/codekita/workspaces/feat-EDU-123-payment-refactor
   # Remove each worktree manually or use git worktree remove
   ```

## Target Repositories

| Repo | Default Branch |
|------|----------------|
| website_backend | master |
| paula-backend | master |
| paula-frontend | main |
| kaya | main |
| leadwise | main |
| alexandria | main |
| nps | main |

## Features

- **Auto branch detection**: Automatically detects `main` or `master` as base branch
- **Safety checks**: Prevents creating duplicate worktrees or branch conflicts
- **Untracked files**: Copies `.env` and other ignored files to worktree
- **Exclusions**: Skips `node_modules`, `vendor`, `dist`, `build`, `.next`, `target`

## Requirements

- macOS or Linux
- Git
- Bash 4+
- No external dependencies

## Notes

- Default branch is auto-detected per repository
- Each repository gets its own worktree with the feature branch checked out
- Untracked files (like `.env`) are copied to maintain environment consistency
- Heavy directories (build artifacts) are excluded to save space

#!/bin/bash

# Home node_modules remover script
# WARNING: This script will delete all node_modules directories found in your home directory.
# Use with caution as it may remove dependencies from your projects.

echo "WARNING: This will remove ALL node_modules directories from your home directory."
echo "This may affect your personal projects and Node.js installations."
echo "Are you sure you want to continue? (yes/no)"

read -r confirmation

if [[ "$confirmation" != "yes" ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo "Searching and removing node_modules directories..."

# Find and remove all node_modules directories in home directory
# Using 2>/dev/null to suppress permission errors
find "$HOME" -name "node_modules" -type d -prune -exec rm -rf {} + 2>/dev/null

echo "Home directory node_modules removal completed."
echo "Note: Some directories may not have been removed due to permissions."

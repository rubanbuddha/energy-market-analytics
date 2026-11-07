#!/usr/bin/env bash
# Usage: ./push_to_github.sh <your-github-username>
set -e

USERNAME="${1:-rubanbuddha}"
REPO_NAME="$(basename "$(pwd)")"

echo "Creating public repo $USERNAME/$REPO_NAME on GitHub..."
gh repo create "$USERNAME/$REPO_NAME" --public --source=. --description "Analytics engineering project: dbt + BigQuery. Part of my Junior Analytics Engineer portfolio." || true

echo "Initialising git..."
git init -b main 2>/dev/null || true
git add .
git commit -m "Initial commit: dbt + BigQuery analytics engineering project" || echo "Nothing to commit."

echo "Pushing..."
git remote add origin "git@github.com:$USERNAME/$REPO_NAME.git" 2>/dev/null || git remote set-url origin "git@github.com:$USERNAME/$REPO_NAME.git"
git push -u origin main

echo ""
echo "Done. Repo: https://github.com/$USERNAME/$REPO_NAME"
echo "Next: pin it to your profile and add topics via 'gh repo edit --add-topic ...'."

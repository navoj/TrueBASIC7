#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

for tool in git gh; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'Error: %s must be installed and available on PATH.\n' "$tool" >&2
        exit 1
    fi
done

branch=$(git branch --show-current)
if [[ "$branch" != main ]]; then
    printf 'Error: switch to the main branch before running this script.\n' >&2
    exit 1
fi

push_urls=$(git remote get-url --push --all origin)
while IFS= read -r url; do
    case "$url" in
        https://github.com/navoj/TrueBASIC7.git|https://github.com/navoj/TrueBASIC7|git@github.com:navoj/TrueBASIC7.git)
            ;;
        *)
            printf 'Error: origin must point to navoj/TrueBASIC7 on github.com; found %s.\n' "$url" >&2
            exit 1
            ;;
    esac
done <<< "$push_urls"

changes=$(git status --porcelain)
if [[ -n "$changes" ]]; then
    printf 'Notice: uncommitted changes will not be pushed. Commit them first to include them.\n' >&2
fi

gh auth switch --hostname github.com --user navoj
gh auth setup-git --hostname github.com
git fetch origin
git push origin main
git status --short --branch

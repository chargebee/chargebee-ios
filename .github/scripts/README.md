# Scripts

## Generate changelog

Lists PRs merged into a branch (excludes "Parent branch sync" and bot-authored PRs).

**Prerequisites:** `jq`, and GitHub credentials as env vars.

### Set credentials (once per terminal)

```bash
export GH_USERNAME=your-github-username
export GH_PAT=your-github-personal-access-token
```

### Commands

From repo root:

| What you want | Command |
|---------------|---------|
| PRs merged into **current branch** (last 30 days) | `./.github/scripts/generate-changelog.sh` |
| PRs merged into **master** (last 30 days) | `./.github/scripts/generate-changelog.sh master` |
| PRs merged into **master** since a date | `./.github/scripts/generate-changelog.sh master "merged:>=2025-01-01"` |

### Arguments

1. **Branch** (optional) — default: current branch  
2. **Date filter** (optional) — default: last 30 days (e.g. `merged:>=2025-01-01`)

Output includes a GitHub search URL to verify results.

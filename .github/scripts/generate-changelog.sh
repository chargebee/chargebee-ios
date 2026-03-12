#!/bin/bash

set -e

# Check required environment variables
if [[ -z "$GH_USERNAME" ]]; then
  echo "❌ Error: Environment variable GH_USERNAME not found"
  exit 1
fi

if [[ -z "$GH_PAT" ]]; then
  echo "❌ Error: Environment variable GH_PAT not found"
  exit 1
fi

# Optional: Branch name (defaults to current branch if not provided)
SOURCE_BRANCH="${1:-$(git branch --show-current)}"
# Optional: Date filter (defaults to last 30 days if not provided)
DATE_FILTER="${2:-merged:>=$(date -u -v-30d +%Y-%m-%d 2>/dev/null || date -u -d '30 days ago' +%Y-%m-%d)}"

# Repo is set per-repo when this file is pushed (placeholder replaced by upload script)
REPO="chargebee/chargebee-ios"

echo "🔍 Searching for PRs merged into $SOURCE_BRANCH..."

# GitHub API call with error handling
HTTP_STATUS=$(curl -s -w "%{http_code}" -G -u "$GH_USERNAME:$GH_PAT" \
  "https://api.github.com/search/issues" \
  --data-urlencode "q=NOT \"Parent branch sync\" in:title is:pr repo:$REPO is:merged base:$SOURCE_BRANCH merged:$DATE_FILTER -author:app/distributed-gitflow-app" \
  -o /tmp/curl_output.json \
  2>/tmp/curl_error.log)

CURL_EXIT_CODE=$?

echo "🌐 API call status: $HTTP_STATUS"

if [ $CURL_EXIT_CODE -ne 0 ]; then
  echo "❌ Error: curl request failed with exit code $CURL_EXIT_CODE"
  echo "Error details: $(cat /tmp/curl_error.log)"
  exit 1
fi

if [ "$HTTP_STATUS" -ne 200 ]; then
  echo "❌ Error: API returned HTTP status $HTTP_STATUS"
  echo "Response: $(cat /tmp/curl_output.json)"
  exit 1
fi

PR_LIST_RESPONSE=$(cat /tmp/curl_output.json)

# Clean invalid control characters from JSON response
if ! echo "$PR_LIST_RESPONSE" | jq . >/dev/null 2>&1; then
  echo "⚠️  Invalid JSON detected — cleaning control characters..."
  PR_LIST_RESPONSE=$(echo "$PR_LIST_RESPONSE" | tr -d '\000-\037')

  if ! echo "$PR_LIST_RESPONSE" | jq . >/dev/null 2>&1; then
    echo "$PR_LIST_RESPONSE" > /tmp/invalid_json_debug.json
    echo "❌ Error: JSON is still invalid after cleaning control characters"
    echo "💡 Use 'cat /tmp/invalid_json_debug.json' to inspect the JSON"
    exit 1
  fi
fi

PR_MERGED_COUNT=$(echo "$PR_LIST_RESPONSE" | jq '.total_count')

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NOCOLOR='\033[0m'

echo "=============================================================================="
echo -e "Found ${GREEN}$PR_MERGED_COUNT${NOCOLOR} PR(s) merged into $SOURCE_BRANCH (filter: $DATE_FILTER)"
echo "=============================================================================="
echo -e "## ${GREEN}CHANGELOG${NOCOLOR}"
echo "$PR_LIST_RESPONSE" | jq -r '.items[] | (.title) + " (" + (.user.login) + ") [#" + (.number | tostring) + "]"' | sort
printf "\n"
echo "=============================================================================="
echo -e "${GREEN}GitHub Search URL (to verify, if required)${NOCOLOR}"
BRANCH_ENCODED=$(echo "$SOURCE_BRANCH" | sed 's/ /%20/g')
echo "https://github.com/$REPO/pulls?q=NOT+%22Parent+branch+sync%22+in%3Atitle+is%3Apr+is%3Amerged+base%3A$BRANCH_ENCODED+merged%3A$DATE_FILTER+-author%3Aapp%2Fdistributed-gitflow-app"
echo "=============================================================================="

# Clean up temporary files
rm -f /tmp/curl_output.json /tmp/curl_error.log

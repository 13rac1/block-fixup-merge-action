#!/bin/bash
set -eo pipefail

main() {
  PR_REF="${GITHUB_REF%/merge}/head"
  BASE_REF="${GITHUB_BASE_REF}"

  echo "Current ref: ${PR_REF}"
  echo "Base ref: ${BASE_REF}"

  if [[ "$PR_REF" != "refs/pull/"* ]]; then
    echo "This check works only with pull_request events"
    exit 1
  fi

  # Using git directly because the $GITHUB_EVENT_PATH file only shows commits in
  # most recent push.
  heading "Fetching base branch"
  /usr/bin/git -c protocol.version=2 fetch --no-tags --prune --progress --no-recurse-submodules --depth=500 origin "${BASE_REF}:__ci_base"
  heading "Fetching PR branch"
  /usr/bin/git -c protocol.version=2 fetch --no-tags --prune --progress --no-recurse-submodules origin "${PR_REF}:__ci_pr"
  
  # Get the list before the "|| true" to fail the script when the git cmd fails.
  COMMIT_LIST=`/usr/bin/git log --pretty=format:'%s %h <- %p ' __ci_base..__ci_pr`

  heading "Commit list"
  echo "$COMMIT_LIST"

  FIXUP_COUNT=`echo "$COMMIT_LIST" | grep fixup! | wc -l || true`
  SQUASH_COUNT=`echo "$COMMIT_LIST" | grep squash! | wc -l || true`
  MERGE_COUNT=`echo "$COMMIT_LIST" | grep -E ' <- ([^ ]+ ){2,}$' | wc -l || true`
  
  heading "Results"
  echo "Fixup! commits: $FIXUP_COUNT"
  echo "Squash! commits: $SQUASH_COUNT"
  echo "Merge commits: $MERGE_COUNT"
  
  if [[ "$FIXUP_COUNT" -gt "0" ]]; then
    heading "Bad commits"
    /usr/bin/git log --pretty=format:%s __ci_base..__ci_pr | grep fixup!
    exit 1
  fi

  if [[ "$SQUASH_COUNT" -gt "0" ]]; then
    heading "Bad commits"
    /usr/bin/git log --pretty=format:%s __ci_base..__ci_pr | grep squash!
    exit 1
  fi

  if [[ "$MERGE_COUNT" -gt "0" ]]; then
    heading "Bad commits"
    /usr/bin/git log --pretty=format:'%s %h <- %p ' __ci_base..__ci_pr | grep -E ' <- ([^ ]+ ){2,}$'
    exit 1
  fi
  
  doubleline
}

heading() {
  doubleline
  echo $1
  line
}
line() {
  echo "------------------------------------------"
}
doubleline() {
  echo "=========================================="
}

main

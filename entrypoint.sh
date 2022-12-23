#!/bin/bash
set -eo pipefail

main() {

  
  PR_REF="${GITHUB_REF%/merge}/head"

  echo "github ref ${GITHUB_REF}"
  # refs/heads/gh-readonly-queue/main/pr-945-59da78f4b2eb1fc44aabdd827b0c4e3fd2577bf3/head

  BASE_REF="${GITHUB_BASE_REF:-main}"

  # empty

  echo "Current ref: ${PR_REF}"
  echo "Base ref: ${BASE_REF}"

  if [[ "$PR_REF" != "refs/pull/"* ] || [ "$PR_REF" != "refs/heads/gh-readonly-queue/"*]]; then
    echo "This check works only with pull_request events"
    exit 1
  fi

  # Using git directly because the $GITHUB_EVENT_PATH file only shows commits in
  # most recent push.
  /usr/bin/git -c protocol.version=2 fetch --no-tags --prune --progress --no-recurse-submodules --depth=1 origin "${BASE_REF}:__ci_base"
  /usr/bin/git -c protocol.version=2 fetch --no-tags --prune --progress --no-recurse-submodules --shallow-exclude="${BASE_REF}" origin "${PR_REF}:__ci_pr"
  # Get the list before the "|| true" to fail the script when the git cmd fails.

  COMMIT_LIST=`/usr/bin/git log --pretty=format:%s __ci_base..__ci_pr`

  echo "COMMIT LIST $COMMIT_LIST"

  FIXUP_COUNT=`echo $COMMIT_LIST | grep fixup! | wc -l || true`
  echo "Fixup! commits: $FIXUP_COUNT"
  if [[ "$FIXUP_COUNT" -gt "0" ]]; then
    /usr/bin/git log --pretty=format:%s __ci_base..__ci_pr | grep fixup!
    echo "failing..."
    exit 1
  fi

  SQUASH_COUNT=`echo $COMMIT_LIST | grep squash! | wc -l || true`
  echo "Squash! commits: $SQUASH_COUNT"
  if [[ "$SQUASH_COUNT" -gt "0" ]]; then
    /usr/bin/git log --pretty=format:%s __ci_base..__ci_pr | grep squash!
    echo "failing..."
    exit 1
  fi
}

main

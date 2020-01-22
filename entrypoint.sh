#!/bin/bash
set -e
set -o pipefail
main() {
  echo "Current ref: ${GITHUB_REF}"
  BRANCH=${GITHUB_REF:11}
  echo "Current branch: ${BRANCH}"

  # Using git directly because the $GITHUB_EVENT_PATH file only shows commits in
  # most recent push.
  git fetch --no-tags --prune --depth=1 origin master
  git fetch --no-tags --prune --shallow-exclude=master origin ${BRANCH}

  # Get the list before the "|| true" to fail the script when the git cmd fails.
  FIXUP_LIST=`git log --pretty=format:%s origin/master..origin/${BRANCH}`
  FIXUP_COUNT=`echo $FIXUP_LIST | grep fixup! | wc -l || true`
  echo "Fixup! commits: ${FIXUP_COUNT}"
  if [ "$FIXUP_COUNT" -gt "0" ]; then
    git log --pretty=format:%s origin/master..origin/${BRANCH} | grep fixup!
    echo "failing..."
    exit 1
  fi
}

main

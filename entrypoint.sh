#!/bin/bash
set -e
set -o pipefail
main() {
  echo "Current ref: ${GITHUB_REF}"
  echo "Current branch: ${GITHUB_REF:11}"
  # Using git directly because the $GITHUB_EVENT_PATH file only shows commits in
  # most recent push.

  FIXUP_COUNT=`git log --pretty=format:%s origin/master..origin/${GITHUB_REF:11} | grep fixup! | wc -l || true`
  echo "Fixup! commits: ${FIXUP_COUNT}"
  if [ "$FIXUP_COUNT" -gt "0" ]; then
    git log --pretty=format:%s origin/master..origin/${GITHUB_REF:11} | grep fixup!
    echo "failing..."
    exit 1
  fi
}

main

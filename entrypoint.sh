#!/bin/bash
set -e
set -o pipefail
main() {
  echo "Current ref: ${GITHUB_REF}"
  BRANCH=${GITHUB_REF:11}
  echo "Current branch: ${BRANCH}"

  if [ "$BRANCH" == "master" ]; then
    echo "No check of master branch needed."
    exit 0
  fi

  # Using git directly because the $GITHUB_EVENT_PATH file only shows commits in
  # most recent push.
  /usr/bin/git -c protocol.version=2 fetch --no-tags --prune --progress --no-recurse-submodules --depth=1 origin master
  /usr/bin/git -c protocol.version=2 fetch --no-tags --prune --progress --no-recurse-submodules --shallow-exclude=master origin ${BRANCH}

  # Get the list before the "|| true" to fail the script when the git cmd fails.
  FIXUP_LIST=`/usr/bin/git log --pretty=format:%s origin/master..origin/${BRANCH}`
  FIXUP_COUNT=`echo $FIXUP_LIST | grep fixup! | wc -l || true`
  echo "Fixup! commits: ${FIXUP_COUNT}"
  if [ "$FIXUP_COUNT" -gt "0" ]; then
    /usr/bin/git log --pretty=format:%s origin/master..origin/${BRANCH} | grep fixup!
    echo "failing..."
    exit 1
  fi
}

main

#!/bin/bash
set -e
set -o pipefail
main() {
  echo "Current branch: ${GITHUB_REF}"

  FIXUP_COUNT=`jq .commits[].message ${GITHUB_EVENT_PATH} | grep fixup! | wc -l || true`
  echo "Fixup! commits: ${FIXUP_COUNT}"
  if [ "$FIXUP_COUNT" -gt "0" ]; then
    echo "Found Fixup! commits, failing"
    exit 1
  fi
}

main

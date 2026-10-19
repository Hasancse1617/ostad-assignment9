#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <m1|m2|m3|m4|m5|m6> "tag message"" >&2
  exit 2
fi
tag="$1"
message="$2"
case "$tag" in m1|m2|m3|m4|m5|m6) ;; *) echo "Invalid milestone tag: $tag" >&2; exit 2 ;; esac
git tag -a "$tag" -m "$message"
git push origin "$tag"

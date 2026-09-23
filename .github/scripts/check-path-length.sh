#!/usr/bin/env bash
# Fails when a file path in the gallery is too long to be installed on Windows.
#
# The product stores the gallery under
#   C:\ProgramData\inray\OPC Router 5\config\solution-gallery\<source id>\
# where <source id> is 8 characters (24 in versions before tp#354132), so up to
# 83 characters precede every path of this repository. Windows limits a full
# path to 259 characters (MAX_PATH 260 including the terminating NUL), which
# leaves 176 characters; the default limit keeps a small safety margin.
set -euo pipefail

export LC_ALL=C.UTF-8

limit="${MAX_SOLUTION_PATH_LENGTH:-170}"
failed=0
longest=0

cd "$(git rev-parse --show-toplevel)"

while IFS= read -r -d '' file; do
  rel="${file#./}"
  len=${#rel}
  if (( len > longest )); then
    longest=$len
  fi
  if (( len > limit )); then
    echo "::error file=${rel}::Path is ${len} characters long (limit ${limit}). Shorten the Solution, Flow or parameter names so the Solution can be installed on Windows."
    failed=1
  fi
done < <(find . -type f -not -path './.git/*' -not -path './.github/*' -not -path './img/*' -print0)

echo "Longest path: ${longest} characters (limit ${limit})."
exit $failed

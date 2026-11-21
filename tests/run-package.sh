#!/bin/sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
archive=${1:?Provide the locally built release ZIP}
python3 "$project_dir/tools/package-release.py" --verify "$archive"
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/harrows-package.XXXXXX")
python3 - "$archive" "$test_dir/mods" <<'PY'
import sys,zipfile
with zipfile.ZipFile(sys.argv[1])as z:z.extractall(sys.argv[2])
PY
# The same economy, stress, restart and release-mode checks run against the extracted package, not the source mod.
HARROWS_TEST_MOD_PATH="$test_dir/mods" "$project_dir/tests/run-sprint11.sh"
HARROWS_TEST_MOD_PATH="$test_dir/mods" "$project_dir/tests/run-documents.sh"
echo "Package extraction and installed-module QA: PASS; files: $test_dir"

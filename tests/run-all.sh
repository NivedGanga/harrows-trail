#!/bin/sh
# Tests create disposable worlds. No live player world is opened by these runners.
set -eu
cd "$(dirname "$0")/.."
./tests/run-documents.sh
./tests/run-sprint1.sh
./tests/run-sprint5.sh
./tests/run-sprint6.sh
./tests/run-sprint6-integration.sh
./tests/run-sprint7.sh
integration_log=$(mktemp "${TMPDIR:-/tmp}/harrows-suite-integration.XXXXXX")
if ./tests/run-sprint7-integration.sh > "$integration_log" 2>&1;then cat "$integration_log";else cat "$integration_log";exit 1;fi
source_world=$(sed -n 's/^Test worlds and logs: //p' "$integration_log")
test -n "$source_world"
./tests/run-sprint6-route.sh "$source_world/world"
./tests/run-sprint7-route.sh "$source_world/world"
./tests/run-sprint8.sh
./tests/run-sprint9.sh
./tests/run-sprint10.sh
./tests/run-sprint11.sh
./tests/run-play-safety.sh
sh -n play tests/run-*.sh
git diff --check

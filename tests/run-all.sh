#!/bin/sh
# Tests create disposable worlds. No live player world is opened by these runners.
set -eu
cd "$(dirname "$0")/.."
./tests/run-sprint1.sh
./tests/run-sprint5.sh
./tests/run-sprint6.sh
./tests/run-sprint6-integration.sh
./tests/run-sprint7.sh
./tests/run-sprint7-integration.sh
./tests/run-sprint8.sh
./tests/run-play-safety.sh
sh -n play tests/run-*.sh
git diff --check

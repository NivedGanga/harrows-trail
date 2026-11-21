#!/bin/sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
source_world=${1:?Provide a disposable world produced by tests/run-sprint7-integration.sh}
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/harrows-late-route-check.XXXXXX")
python3 - "$source_world" "$test_dir/world" <<'PY'
import shutil,sys
shutil.copytree(sys.argv[1],sys.argv[2],ignore=shutil.ignore_patterns('worldmods'))
PY
mkdir -p "$test_dir/world/worldmods"
cp -R "$project_dir/tests/sprint6_route_test" "$test_dir/world/worldmods/"
cp "$project_dir/tests/sprint7_routes.json" "$test_dir/world/worldmods/sprint6_route_test/path.json"
printf 'bind_address = 127.0.0.1\nserver_announce = false\nharrows_trail_test = true\n' > "$test_dir/test.conf"
if ! LUANTI_USER_PATH="$project_dir/.local/user" LUANTI_GAME_PATH="$project_dir/.local/games" LUANTI_MOD_PATH="$project_dir/mod" \
 "$project_dir/.local/luanti.app/Contents/MacOS/luanti" --server --world "$test_dir/world" --config "$test_dir/test.conf" --port 30985 --logfile "$test_dir/test.log" > "$test_dir/out" 2>&1; then
 cat "$test_dir/out"; echo "Route test failed; files: $test_dir" >&2; exit 1
fi
rg '\[route_validation\].*corridor_failures=0 ' "$test_dir/test.log"
rg '\[route_validation\] paths_passed=6' "$test_dir/test.log"
echo "Test world and logs: $test_dir"

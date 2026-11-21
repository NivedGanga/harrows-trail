#!/bin/sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/harrows-documents.XXXXXX")
mkdir -p "$test_dir/world/worldmods"
cp -R "$project_dir/tests/document_test" "$test_dir/world/worldmods/"
printf 'gameid = mineclonia\nbackend = sqlite3\nplayer_backend = sqlite3\nauth_backend = sqlite3\nmod_storage_backend = sqlite3\nload_mod_harrows_trail = true\n' > "$test_dir/world/world.mt"
printf 'bind_address = 127.0.0.1\nserver_announce = false\nharrows_trail_test = true\n' > "$test_dir/test.conf"
if ! LUANTI_USER_PATH="$project_dir/.local/user" LUANTI_GAME_PATH="$project_dir/.local/games" LUANTI_MOD_PATH="${HARROWS_TEST_MOD_PATH:-$project_dir/mod}" \
 "$project_dir/.local/luanti.app/Contents/MacOS/luanti" --server --world "$test_dir/world" --config "$test_dir/test.conf" --port 30985 --logfile "$test_dir/test.log" > "$test_dir/out" 2>&1;then
 cat "$test_dir/out";echo "Document regression failed; files: $test_dir" >&2;exit 1
fi
rg '\[document_test\] PASS' "$test_dir/test.log"
echo "Test world and logs: $test_dir"

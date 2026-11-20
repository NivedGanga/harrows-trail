#!/bin/sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
engine="$project_dir/.local/luanti.app/Contents/MacOS/luanti"
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/harrows-sprint6.XXXXXX")
for phase in write read blocked modified modified_read; do
 case "$phase" in blocked) world_dir="$test_dir/blocked-world" ;; modified|modified_read) world_dir="$test_dir/modified-world" ;; *) world_dir="$test_dir/world" ;; esac
 if [ "$phase" != read ] && [ "$phase" != modified_read ]; then
  mkdir -p "$world_dir/worldmods"
  printf 'gameid = mineclonia\nbackend = sqlite3\nplayer_backend = files\nauth_backend = files\nload_mod_harrows_trail = true\n' > "$world_dir/world.mt"
  cp -R "$project_dir/tests/sprint6_test" "$world_dir/worldmods/"
 fi
 printf 'bind_address = 127.0.0.1\nserver_announce = false\nfixed_map_seed = 1730940739604968791\nharrows_trail_test = true\nharrows_sprint6_phase = %s\n' "$phase" > "$test_dir/$phase.conf"
 if ! LUANTI_USER_PATH="$project_dir/.local/user" LUANTI_GAME_PATH="$project_dir/.local/games" LUANTI_MOD_PATH="$project_dir/mod" \
  "$engine" --server --world "$world_dir" --config "$test_dir/$phase.conf" --port 30985 --logfile "$test_dir/$phase.log" > "$test_dir/$phase.out" 2>&1; then
  cat "$test_dir/$phase.out"; echo "Sprint 6 test failed; files: $test_dir" >&2; exit 1
 fi
 if ! rg -q "\[sprint6_test\] PASS $phase" "$test_dir/$phase.log"; then
  cat "$test_dir/$phase.out"; echo "Sprint 6 test failed; files: $test_dir" >&2; exit 1
 fi
 echo "PASS: $phase"
done
echo "Test worlds and logs: $test_dir"

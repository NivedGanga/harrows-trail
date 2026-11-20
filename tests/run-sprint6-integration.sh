#!/bin/sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/harrows-midgame-integration.XXXXXX")
mkdir -p "$test_dir/world/worldmods"
printf 'gameid = mineclonia\nbackend = sqlite3\nplayer_backend = files\nauth_backend = files\nload_mod_harrows_trail = true\n' > "$test_dir/world/world.mt"
cp -R "$project_dir/tests/sprint6_integration_test" "$test_dir/world/worldmods/"
for phase in write read; do
 printf 'bind_address = 127.0.0.1\nserver_announce = false\nfixed_map_seed = 1730940739604968791\nharrows_trail_grounded = true\nharrows_trail_test = true\nharrows_sprint6_integration_phase = %s\n' "$phase" > "$test_dir/$phase.conf"
 if ! LUANTI_USER_PATH="$project_dir/.local/user" LUANTI_GAME_PATH="$project_dir/.local/games" LUANTI_MOD_PATH="$project_dir/mod" \
  "$project_dir/.local/luanti.app/Contents/MacOS/luanti" --server --world "$test_dir/world" --config "$test_dir/$phase.conf" --port 30985 --logfile "$test_dir/$phase.log" > "$test_dir/$phase.out" 2>&1; then
  cat "$test_dir/$phase.out"; echo "Integration failed; files: $test_dir" >&2; exit 1
 fi
 rg "\[sprint6_integration\] PASS $phase" "$test_dir/$phase.log"
done
echo "Test worlds and logs: $test_dir"

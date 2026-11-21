#!/bin/sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
python3 "$project_dir/tests/check-audio.py"
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/harrows-atmosphere.XXXXXX")
for phase in write read missing; do
 phase_mod_path="$project_dir/mod"
 world_dir="$test_dir/world"
 if [ "$phase" = missing ]; then world_dir="$test_dir/missing-world";fi
 if [ "$phase" != read ]; then
  mkdir -p "$world_dir/worldmods"
  printf 'gameid = mineclonia\nbackend = sqlite3\nplayer_backend = files\nauth_backend = files\nload_mod_harrows_trail = true\n' > "$world_dir/world.mt"
  cp -R "$project_dir/tests/sprint10_test" "$world_dir/worldmods/"
 fi
 if [ "$phase" = missing ]; then
  phase_mod_path="$test_dir/empty-mods";mkdir -p "$phase_mod_path"
  cp -R "$project_dir/mod/harrows_trail" "$world_dir/worldmods/"
  rm -f "$world_dir/worldmods/harrows_trail/sounds/"*.ogg "$world_dir/worldmods/harrows_trail/textures/harrows_ada.png" "$world_dir/worldmods/harrows_trail/textures/harrows_dust.png" "$world_dir/worldmods/harrows_trail/textures/harrows_wood.png"
 fi
 printf 'bind_address = 127.0.0.1\nserver_announce = false\nfixed_map_seed = 1730940739604968791\nharrows_trail_grounded = true\nharrows_trail_test = true\nharrows_sprint10_phase = %s\n' "$phase" > "$test_dir/$phase.conf"
 if ! LUANTI_USER_PATH="$project_dir/.local/user" LUANTI_GAME_PATH="$project_dir/.local/games" LUANTI_MOD_PATH="$phase_mod_path" \
  "$project_dir/.local/luanti.app/Contents/MacOS/luanti" --server --world "$world_dir" --config "$test_dir/$phase.conf" --port 30985 --logfile "$test_dir/$phase.log" > "$test_dir/$phase.out" 2>&1;then
  cat "$test_dir/$phase.out";echo "Atmosphere test failed; files: $test_dir" >&2;exit 1
 fi
 rg "\[sprint10_test\].*(PASS|server_update)" "$test_dir/$phase.log"
done
echo "Test worlds and logs: $test_dir"

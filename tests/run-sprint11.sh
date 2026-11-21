#!/bin/sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/harrows-release-qa.XXXXXX")
for phase in write read release;do
 world_dir="$test_dir/world";if [ "$phase" = release ];then world_dir="$test_dir/release-world";fi
 if [ "$phase" != read ];then
  mkdir -p "$world_dir/worldmods";cp -R "$project_dir/tests/sprint11_test" "$world_dir/worldmods/"
  printf 'gameid = mineclonia\nbackend = sqlite3\nplayer_backend = sqlite3\nauth_backend = sqlite3\nmod_storage_backend = sqlite3\nload_mod_harrows_trail = true\n' > "$world_dir/world.mt"
 fi
 test_mode=true;if [ "$phase" = release ];then test_mode=false;fi
 printf 'bind_address = 127.0.0.1\nserver_announce = false\nfixed_map_seed = 1730940739604968791\nharrows_trail_grounded = true\nharrows_trail_test = %s\nharrows_sprint11_phase = %s\n' "$test_mode" "$phase" > "$test_dir/$phase.conf"
 if ! LUANTI_USER_PATH="$project_dir/.local/user" LUANTI_GAME_PATH="$project_dir/.local/games" LUANTI_MOD_PATH="${HARROWS_TEST_MOD_PATH:-$project_dir/mod}" \
  "$project_dir/.local/luanti.app/Contents/MacOS/luanti" --server --world "$world_dir" --config "$test_dir/$phase.conf" --port 30985 --logfile "$test_dir/$phase.log" > "$test_dir/$phase.out" 2>&1;then
  cat "$test_dir/$phase.out";echo "Release QA failed; files: $test_dir" >&2;exit 1
 fi
 rg "\[sprint11_test\].*(PASS|stress_npcs)" "$test_dir/$phase.log"
done
echo "Test worlds and logs: $test_dir"

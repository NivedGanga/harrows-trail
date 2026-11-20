#!/bin/sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
engine="$project_dir/.local/luanti.app/Contents/MacOS/luanti"
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/harrows-death.XXXXXX")
world_dir="$test_dir/world"
mkdir -p "$world_dir/worldmods" "$test_dir/user"
cp -R "$project_dir/.local/world/." "$world_dir/"
printf '\nload_mod_harrows_trail = true\n' >> "$world_dir/world.mt"
cp -R "$project_dir/tests/sprint4_death" "$world_dir/worldmods/"
for phase in write read; do
 printf 'bind_address = 127.0.0.1\nserver_announce = false\nenable_damage = true\nharrows_trail_test = true\nharrows_death_phase = %s\n' "$phase" > "$test_dir/$phase.conf"
 if [ "$phase" = write ]; then
  LUANTI_USER_PATH="$test_dir/user" LUANTI_GAME_PATH="$project_dir/.local/games" LUANTI_MOD_PATH="$project_dir/mod" "$engine" --world "$world_dir" --go --name sprint4_death_player --config "$test_dir/$phase.conf" --port 30994 --logfile "$test_dir/$phase.log" > "$test_dir/$phase.out" 2>&1
 else
  LUANTI_USER_PATH="$test_dir/user" LUANTI_GAME_PATH="$project_dir/.local/games" LUANTI_MOD_PATH="$project_dir/mod" "$engine" --server --world "$world_dir" --config "$test_dir/$phase.conf" --port 30994 --logfile "$test_dir/$phase.log" > "$test_dir/$phase.out" 2>&1
 fi
 if ! rg -q "\[sprint4_death\] PASS $phase" "$test_dir/$phase.log"; then
  cat "$test_dir/$phase.out"
  echo "Sprint 4 death test failed; files: $test_dir" >&2
  exit 1
 fi
 echo "PASS: death $phase"
done
echo "Test world and logs: $test_dir"

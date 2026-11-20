#!/bin/sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
engine="$project_dir/.local/luanti.app/Contents/MacOS/luanti"
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/harrows-sprint1.XXXXXX")
world_dir="$test_dir/world"
mkdir -p "$world_dir/worldmods"
cp -R "$project_dir/.local/world/." "$world_dir/"
cp "$world_dir/world.mt" "$test_dir/world.mt.before"
printf '\nload_mod_harrows_trail = true\n' >> "$world_dir/world.mt"
cp -R "$project_dir/tests/sprint1_test" "$world_dir/worldmods/"
for phase in write read; do
  printf 'bind_address = 127.0.0.1\nserver_announce = false\nharrows_trail_test = true\nharrows_trail_test_phase = %s\n' "$phase" > "$test_dir/$phase.conf"
  LUANTI_USER_PATH="$project_dir/.local/user" LUANTI_GAME_PATH="$project_dir/.local/games" LUANTI_MOD_PATH="$project_dir/mod" \
    "$engine" --server --world "$world_dir" --config "$test_dir/$phase.conf" --port 30985 --logfile "$test_dir/$phase.log" > "$test_dir/$phase.out" 2>&1
  if ! rg -q "\[sprint1_test\] PASS phase $phase" "$test_dir/$phase.log"; then
    cat "$test_dir/$phase.out"
    echo "Sprint 1 test failed; files: $test_dir" >&2
    exit 1
  fi
  echo "PASS: $phase"
done
blocked_world="$test_dir/blocked-world"
mkdir -p "$blocked_world/worldmods"
cp -R "$project_dir/.local/world/." "$blocked_world/"
cp "$blocked_world/world.mt" "$test_dir/blocked-world.mt.before"
printf '\nload_mod_harrows_trail = true\n' >> "$blocked_world/world.mt"
cp -R "$project_dir/tests/sprint1_test" "$blocked_world/worldmods/"
printf 'bind_address = 127.0.0.1\nserver_announce = false\nharrows_trail_test = true\nharrows_trail_test_phase = blocked\n' > "$test_dir/blocked.conf"
LUANTI_USER_PATH="$project_dir/.local/user" LUANTI_GAME_PATH="$project_dir/.local/games" LUANTI_MOD_PATH="$project_dir/mod" \
  "$engine" --server --world "$blocked_world" --config "$test_dir/blocked.conf" --port 30985 --logfile "$test_dir/blocked.log" > "$test_dir/blocked.out" 2>&1
if ! rg -q '\[sprint1_test\] PASS phase blocked' "$test_dir/blocked.log"; then
  cat "$test_dir/blocked.out"
  echo "Sprint 1 occupied-site test failed; files: $test_dir" >&2
  exit 1
fi
echo 'PASS: occupied site preserved (expected site-occupied error in log)'
printf 'bind_address = 127.0.0.1\nserver_announce = false\nharrows_trail_test = true\nharrows_trail_test_phase = survey\n' > "$test_dir/survey.conf"
LUANTI_USER_PATH="$project_dir/.local/user" LUANTI_GAME_PATH="$project_dir/.local/games" LUANTI_MOD_PATH="$project_dir/mod" \
  "$engine" --server --world "$world_dir" --config "$test_dir/survey.conf" --port 30985 --logfile "$test_dir/survey.log" > "$test_dir/survey.out" 2>&1
if ! rg -q '\[sprint1_test\] PASS phase survey' "$test_dir/survey.log"; then
  cat "$test_dir/survey.out"
  echo "Sprint 1 site survey failed; files: $test_dir" >&2
  exit 1
fi
rg '\[sprint1_test\] survey' "$test_dir/survey.log"
echo "Test world and logs: $test_dir"

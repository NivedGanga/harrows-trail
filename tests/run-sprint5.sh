#!/bin/sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
engine="$project_dir/.local/luanti.app/Contents/MacOS/luanti"
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/harrows-sprint5.XXXXXX")
for phase in fresh integration integration_read legacy_grounded_write legacy_grounded_read dynamic bad_seed write read blocked legacy_write legacy_read; do
 if [ "$phase" = blocked ]; then world_dir="$test_dir/blocked-world"; elif [ "$phase" = dynamic ]; then world_dir="$test_dir/dynamic-world"; elif [ "$phase" = bad_seed ]; then world_dir="$test_dir/bad-seed-world"; elif [ "$phase" = legacy_grounded_write ] || [ "$phase" = legacy_grounded_read ]; then world_dir="$test_dir/legacy-grounded-world"; elif [ "$phase" = legacy_write ] || [ "$phase" = legacy_read ]; then world_dir="$test_dir/legacy-world"; elif [ "$phase" = fresh ] || [ "$phase" = integration ] || [ "$phase" = integration_read ]; then world_dir="$test_dir/fresh-world"; else world_dir="$test_dir/world"; fi
 if [ "$phase" = legacy_grounded_write ]; then cp -R "$test_dir/fresh-world" "$world_dir"; fi
 if [ "$phase" != read ] && [ "$phase" != integration ] && [ "$phase" != integration_read ] && [ "$phase" != legacy_read ] && [ "$phase" != legacy_grounded_write ] && [ "$phase" != legacy_grounded_read ]; then
  mkdir -p "$world_dir/worldmods"
  if [ "$phase" = fresh ] || [ "$phase" = dynamic ] || [ "$phase" = bad_seed ]; then
   printf 'gameid = mineclonia\nbackend = sqlite3\nplayer_backend = files\nauth_backend = files\n' > "$world_dir/world.mt"
  else
   cp -R "$project_dir/.local/world/." "$world_dir/"
  fi
  printf '\nload_mod_harrows_trail = true\n' >> "$world_dir/world.mt"
  cp -R "$project_dir/tests/sprint5_test" "$world_dir/worldmods/"
 fi
 if [ "$phase" = legacy_write ]; then grounded=false; else grounded=true; fi
 if [ "$phase" = bad_seed ]; then seed=1; else seed=1730940739604968791; fi
 printf 'bind_address = 127.0.0.1\nserver_announce = false\nfixed_map_seed = %s\nharrows_trail_grounded = %s\nharrows_trail_test = true\nharrows_sprint5_phase = %s\n' "$seed" "$grounded" "$phase" > "$test_dir/$phase.conf"
 if ! LUANTI_USER_PATH="$project_dir/.local/user" LUANTI_GAME_PATH="$project_dir/.local/games" LUANTI_MOD_PATH="$project_dir/mod" \
  "$engine" --server --world "$world_dir" --config "$test_dir/$phase.conf" --port 30985 --logfile "$test_dir/$phase.log" > "$test_dir/$phase.out" 2>&1; then
  cat "$test_dir/$phase.out"
  echo "Sprint 5 test failed; files: $test_dir" >&2
  exit 1
 fi
 if ! rg -q "\[sprint5_test\] PASS $phase" "$test_dir/$phase.log"; then
  cat "$test_dir/$phase.out"
  echo "Sprint 5 test failed; files: $test_dir" >&2
  exit 1
 fi
 echo "PASS: $phase"
done
echo "Test worlds and logs: $test_dir"

#!/bin/sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/harrows-launch.XXXXXX")
mkdir -p "$test_dir/.local/luanti.app/Contents/MacOS" "$test_dir/.local/play-world" "$test_dir/mod"
cp "$project_dir/play" "$test_dir/play"
printf 'preserve\n' > "$test_dir/.local/play-world/sentinel"
cat > "$test_dir/.local/luanti.app/Contents/MacOS/luanti" <<'STUB'
#!/bin/sh
exit 0
STUB
chmod +x "$test_dir/.local/luanti.app/Contents/MacOS/luanti"
output=$("$test_dir/play")
world_dir=${output#Harrow test world: }
test -f "$test_dir/.local/play-world/sentinel"
test -f "$world_dir/.harrows-play-disposable"
test -f "$world_dir/harrows.conf"
printf 'preserve\n' > "$world_dir/sentinel"
HARROWS_WORLD="$world_dir" "$test_dir/play" > /dev/null
test -f "$world_dir/sentinel"
mkdir "$world_dir/.harrows-session.lock"
if HARROWS_WORLD="$world_dir" "$test_dir/play" > /dev/null 2>&1; then echo 'Failed to reject a locked world' >&2; exit 1; fi
test -f "$world_dir/sentinel"
if HARROWS_WORLD="$test_dir/.local/play-world" "$test_dir/play" > /dev/null 2>&1; then echo 'Failed to reject an unmarked world' >&2; exit 1; fi
echo "PASS: launcher preserves worlds and rejects locked or unmarked paths; files: $test_dir"

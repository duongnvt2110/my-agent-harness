#!/usr/bin/env bash
set -euo pipefail

script="scripts/finalize-task.sh"

# Completion files must include time, not only date, so reusing the same task_id
# on the same day does not collide with an existing completed audit file.
grep -q "completed_stamp=\"\$(date '+%Y_%m_%d_%H%M%S')\"" "$script" || {
  echo "finalize-task.sh must include HHMMSS in completed plan filenames" >&2
  exit 1
}

grep -q '\${completed_stamp}_\${task_id}' "$script" || {
  echo "finalize-task.sh must build completed filenames from completed_stamp and task_id" >&2
  exit 1
}

grep -q 'while \[ -e "\$completed_dir/\${completed_stamp}_\${task_id}_\${suffix}\.md" \]' "$script" || {
  echo "finalize-task.sh must handle same-second completed-file collisions with a suffix" >&2
  exit 1
}

if grep -q 'mv -f "\$PLAN_PATH" "\$completed_file"' "$script"; then
  echo "finalize-task.sh must not force-overwrite completed plans" >&2
  exit 1
fi

grep -q 'mv "\$PLAN_PATH" "\$completed_file"' "$script" || {
  echo "finalize-task.sh must move the active plan without force overwrite" >&2
  exit 1
}

echo "Finalize unique completed file regression passed."

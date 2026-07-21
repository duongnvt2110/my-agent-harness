#!/usr/bin/env bash
set -euo pipefail

for id in BROWN-006 BROWN-007 BROWN-008 BROWN-009 BROWN-010; do
  dir="benchmarks/brownfield/$id"
  [ -f "$dir/task.md" ]
  [ -f "$dir/metadata.json" ]
  [ -f "$dir/expected.patch" ]
  [ -d "$dir/repo" ]
  [ -d "$dir/solution" ]
  [ -x "$dir/tests/fail_to_pass.sh" ]
  [ -x "$dir/tests/pass_to_pass.sh" ]
done

python3 - <<'PYINNER'
import importlib.util
spec = importlib.util.spec_from_file_location('benchmark', 'scripts/benchmark.py')
benchmark = importlib.util.module_from_spec(spec)
spec.loader.exec_module(benchmark)

import pathlib
import tempfile
with tempfile.TemporaryDirectory() as tmp_name:
    tmp = pathlib.Path(tmp_name)
    solution = tmp / 'solution'
    work = tmp / 'work'
    (solution / 'src' / '__pycache__').mkdir(parents=True)
    (solution / 'src' / 'app.py').write_text('print(1)\n')
    (solution / 'src' / '__pycache__' / 'app.cpython-313.pyc').write_bytes(b'cache')
    changed = benchmark.copy_solution_files(solution, work)
    assert changed == ['src/app.py'], changed
    assert not (work / 'src' / '__pycache__').exists()

row = benchmark.run_brownfield_issue_resolution(None, 20)
assert row['result'] == 'pass', row
assert row['score'] == 25, row
assert row['metrics']['tasks_total'] == 5, row
assert row['metrics']['tasks_passed'] == 5, row
for task in row['metrics']['tasks']:
    assert task['allowed_files_only'], task
    assert task['commands']['pre_patch_fail_to_pass']['exit_code'] != 0, task
    assert task['commands']['post_patch_fail_to_pass']['exit_code'] == 0, task
    assert task['commands']['post_patch_pass_to_pass']['exit_code'] == 0, task
PYINNER

echo "Brownfield benchmark regression passed."

#!/usr/bin/env bash
set -euo pipefail
validation_dir=$(cd "$(dirname "$0")" && pwd)
firmware_dir=$(cd "$validation_dir/.." && pwd)
source_dir="$firmware_dir/upstream/tangara-fw"
revision=c092c5aae83aac241b3756b15d8b9dad9ed2c3fd
idf_revision=8c750b088c7cd857d079c0eeb495da199b359461
python_cmd=${HARMONY_PYTHON:-python3.12}
"$python_cmd" -c 'import sys; assert sys.version_info[:2] == (3, 12), "Use Python 3.12 for the recorded toolchain"'

mkdir -p "$firmware_dir/upstream" "$validation_dir/logs"
if [ ! -d "$source_dir/.git" ]; then
  git clone https://codeberg.org/cool-tech-zone/tangara-fw.git "$source_dir"
  git -C "$source_dir" checkout --detach "$revision"
fi
test "$(git -C "$source_dir" rev-parse HEAD)" = "$revision"
test -z "$(git -C "$source_dir" status --porcelain --untracked-files=no)"
git -C "$source_dir" submodule update --init --recursive --depth 1
test "$(git -C "$source_dir/lib/esp-idf" rev-parse HEAD)" = "$idf_revision"
export IDF_TOOLS_PATH="$firmware_dir/toolchains/esp-idf"
"$python_cmd" "$source_dir/lib/esp-idf/tools/idf_tools.py" install --targets=esp32
"$python_cmd" "$source_dir/lib/esp-idf/tools/idf_tools.py" install-python-env

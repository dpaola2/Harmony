#!/usr/bin/env bash
# Builds only. Does not detect a serial port or flash a device.
set -eo pipefail
validation_dir=$(cd "$(dirname "$0")" && pwd)
firmware_dir=$(cd "$validation_dir/.." && pwd)
source_dir="$firmware_dir/upstream/tangara-fw"
test "$(git -C "$source_dir" rev-parse HEAD)" = c092c5aae83aac241b3756b15d8b9dad9ed2c3fd
test "$(git -C "$source_dir/lib/esp-idf" rev-parse HEAD)" = 8c750b088c7cd857d079c0eeb495da199b359461
test -z "$(git -C "$source_dir" status --porcelain --untracked-files=no)"
test ! -e "$source_dir/sdkconfig.local"
if [ -f "$source_dir/sdkconfig" ]; then
  cmp "$validation_dir/configuration/sdkconfig" "$source_dir/sdkconfig"
fi
export IDF_TOOLS_PATH="$firmware_dir/toolchains/esp-idf"
export PATH="$IDF_TOOLS_PATH/python_env/idf5.5_py3.12_env/bin:$PATH"
cd "$source_dir"
. ./.env
idf.py build

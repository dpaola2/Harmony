#!/usr/bin/env bash
set -eo pipefail
test_dir=$(cd "$(dirname "$0")" && pwd)
firmware_dir=$(cd "$test_dir/../.." && pwd)
export IDF_PATH="$firmware_dir/upstream/tangara-fw/lib/esp-idf"
test "$(git -C "$IDF_PATH" rev-parse HEAD)" = 8c750b088c7cd857d079c0eeb495da199b359461
export IDF_TOOLS_PATH="$firmware_dir/toolchains/esp-idf"
export PATH="$IDF_TOOLS_PATH/python_env/idf5.5_py3.12_env/bin:$PATH"
. "$IDF_PATH/export.sh"
cd "$test_dir"
idf.py "$@"

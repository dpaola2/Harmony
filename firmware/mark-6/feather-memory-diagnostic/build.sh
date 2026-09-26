#!/usr/bin/env bash
set -eo pipefail
# Build/configuration only. Flashing requires a separate hardware session.
if [ "$#" -eq 0 ]; then set -- build; fi
for arg in "$@"; do
    case "$arg" in
        build|size|size-components|menuconfig|reconfigure|fullclean) ;;
        *) echo "Unsupported action: $arg. This preparation script cannot flash hardware." >&2; exit 2 ;;
    esac
done
export IDF_TARGET=esp32
test_dir=$(cd "$(dirname "$0")" && pwd)
firmware_dir=$(cd "$test_dir/../.." && pwd)
export IDF_PATH="$firmware_dir/upstream/tangara-fw/lib/esp-idf"
test "$(git -C "$IDF_PATH" rev-parse HEAD)" = 8c750b088c7cd857d079c0eeb495da199b359461
export IDF_TOOLS_PATH="$firmware_dir/toolchains/esp-idf"
export PATH="$IDF_TOOLS_PATH/python_env/idf5.5_py3.12_env/bin:$PATH"
. "$IDF_PATH/export.sh"
cd "$test_dir"
idf.py "$@"

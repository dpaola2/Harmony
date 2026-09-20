#!/usr/bin/env bash
set -euo pipefail

root_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
validation_dir="$root_dir/samd-validation"
app_source="$root_dir/upstream/tangara-samd"
boot_source="$root_dir/upstream/tangara-samd-bootloader"
toolchain_dir="$root_dir/toolchains/samd"
cache_dir="$root_dir/.cache"

app_revision=8066c54bff5d26398fa08955d2bc24e7f05702a2
boot_revision=bc1632d9736493467000ba119fd0b16fd46ccbe6
app_tinyusb_revision=5217cee5de4cd555018da90f9f1bcc87fb1c1d3a
uf2_revision=35842c770bf553ce01a48ded68f3763e5e140a1e
hidapi_revision=a6a622ffb680c55da0de787ff93b80280498330f
toolchain_archive="$cache_dir/arm-gnu-toolchain-14.3.rel1-darwin-arm64-arm-none-eabi.tar.xz"
toolchain_url=https://developer.arm.com/-/media/Files/downloads/gnu/14.3.rel1/binrel/arm-gnu-toolchain-14.3.rel1-darwin-arm64-arm-none-eabi.tar.xz
toolchain_sha256=30f4d08b219190a37cded6aa796f4549504902c53cfc3c7e044a8490b6eba1f7

mkdir -p "$root_dir/upstream" "$cache_dir"
if [[ ! -d "$app_source/.git" ]]; then
  git clone https://codeberg.org/cool-tech-zone/tangara-samd-fw.git "$app_source"
fi
if [[ ! -d "$boot_source/.git" ]]; then
  git clone https://git.sr.ht/~jacqueline/tangara-samd-bootloader "$boot_source"
fi

git -C "$app_source" checkout --detach "$app_revision"
git -C "$app_source" submodule update --init --recursive
git -C "$boot_source" checkout --detach "$boot_revision"
git -C "$boot_source" submodule update --init --recursive

if [[ ! -f "$toolchain_archive" ]]; then
  curl -fL --retry 3 -o "$toolchain_archive" "$toolchain_url"
fi
printf '%s  %s\n' "$toolchain_sha256" "$toolchain_archive" | shasum -a 256 -c -
if [[ ! -x "$toolchain_dir/bin/arm-none-eabi-gcc" ]]; then
  mkdir -p "$toolchain_dir"
  tar -xJf "$toolchain_archive" -C "$toolchain_dir" --strip-components=1
fi

test "$(git -C "$app_source" rev-parse HEAD)" = "$app_revision"
test "$(git -C "$boot_source" rev-parse HEAD)" = "$boot_revision"
test -z "$(git -C "$app_source" status --porcelain --untracked-files=normal)"
test -z "$(git -C "$boot_source" status --porcelain --untracked-files=normal)"
test "$(git -C "$app_source/tinyusb" rev-parse HEAD)" = "$app_tinyusb_revision"
test "$(git -C "$app_source/tools/uf2" rev-parse HEAD)" = "$uf2_revision"
test "$(git -C "$app_source/tools/uf2/hidapi" rev-parse HEAD)" = "$hidapi_revision"
test "$(git -C "$boot_source/lib/uf2" rev-parse HEAD)" = "$uf2_revision"
test "$(git -C "$boot_source/lib/uf2/hidapi" rev-parse HEAD)" = "$hidapi_revision"
test -z "$(git -C "$app_source" submodule status --recursive | grep -E '^[+-U]' || true)"
test -z "$(git -C "$boot_source" submodule status --recursive | grep -E '^[+-U]' || true)"

export PATH="$toolchain_dir/bin:/opt/homebrew/bin:/usr/bin:/bin"
mkdir -p "$validation_dir/build/application" "$validation_dir/logs" "$validation_dir/artifacts"

arm-none-eabi-gcc --version > "$validation_dir/logs/toolchain-version.log"
cmake -S "$app_source" -B "$validation_dir/build/application" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo 2>&1 | tee "$validation_dir/logs/application-configure.log"
cmake --build "$validation_dir/build/application" --clean-first --parallel 8 \
  2>&1 | tee "$validation_dir/logs/application-build.log"

make -C "$boot_source" BOARD=tangara clean
make -C "$boot_source" BOARD=tangara -j8 \
  2>&1 | tee "$validation_dir/logs/bootloader-build.log"

cp "$validation_dir/build/application/app/application" "$validation_dir/artifacts/tangara-samd-v6.0.elf"
cp "$validation_dir/build/application/tangara.bin" "$validation_dir/artifacts/tangara-samd-v6.0.bin"
cp "$validation_dir/build/application/tangara.uf2" "$validation_dir/artifacts/tangara-samd-v6.0.uf2"
cp "$boot_source/build/tangara/bootloader-tangara-bc1632d.bin" "$validation_dir/artifacts/"
cp "$boot_source/build/tangara/bootloader-tangara-bc1632d.elf" "$validation_dir/artifacts/"
cp "$boot_source/build/tangara/update-bootloader-tangara-bc1632d.uf2" "$validation_dir/artifacts/"

(cd "$validation_dir/artifacts" && shasum -a 256 ./*.elf ./*.bin ./*.uf2 > SHA256SUMS)
arm-none-eabi-size "$validation_dir/artifacts/"*.elf > "$validation_dir/logs/artifact-sizes.log"

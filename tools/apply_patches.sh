#!/usr/bin/env bash
# Apply patches/*.patch to the rexglue-sdk submodule (thirdparty/rexglue-sdk). Safe to run again.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
sdk="$root/thirdparty/rexglue-sdk"
patches=("$root"/patches/*.patch)

if git -C "$sdk" apply --reverse --check "${patches[@]}" 2>/dev/null; then
  echo "Patches already applied."
  exit 0
fi
git -C "$sdk" apply --check "${patches[@]}"
git -C "$sdk" apply "${patches[@]}"
echo "Applied ${#patches[@]} patches to thirdparty/rexglue-sdk."

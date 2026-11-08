#!/usr/bin/env bash
# Launch Singularity (patched SDK build) on the NVIDIA GPU.
#
#   tools/run.sh [extra runtime args...]
#   SINGULARITY_BUILD=local-release tools/run.sh     # use another build preset folder
#
# The runtime backs guest memory with a /dev/shm/xenia_memory_* segment and does not remove it
# when the process hard-exits or crashes. Leftovers fill /dev/shm (tmpfs) and the next run dies
# with SIGBUS ("Bus error") while touching guest memory. Remove segments no process has open.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
build="${SINGULARITY_BUILD:-linux-amd64-release}"
game="${SINGULARITY_GAME_ROOT:-$root/singularity-extract}"

for seg in /dev/shm/xenia_memory_*; do
  [ -e "$seg" ] || continue
  if ! fuser -s "$seg" 2>/dev/null; then
    rm -f "$seg"
  fi
done

cd "$root"
exec env __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only \
  "./out/build/$build/singularity" --game_data_root "$game" "$@"

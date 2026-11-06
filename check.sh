#!/usr/bin/env bash
# TXLF 2026 pre-flight: everything the workshop needs, in one check.
# `./build.py doctor` covers podman/fuse/disk; this adds cosign (step 07) and
# qemu (step 05), which doctor does not know about.
set -uo pipefail

missing=0

check() { # label, command...
  local label="$1"; shift
  if "$@" >/dev/null 2>&1; then
    printf '  ok      %s\n' "$label"
  else
    printf '  MISSING %s\n' "$label"
    missing=$((missing + 1))
  fi
}

echo "TXLF 2026 pre-flight"
echo

check "podman"   podman --version
check "python3"  python3 --version
check "git"      git --version
check "/dev/fuse" test -c /dev/fuse
check ">= 20 GiB free" sh -c 'test "$(df -k . | awk "NR==2 {print \$4}")" -ge $((20 * 1024 * 1024))'
check "cosign (step 07)" cosign version
check "qemu (step 05)"   qemu-system-x86_64 --version

echo
if [ "$missing" -eq 0 ]; then
  echo "All prerequisites present. Continue with ./build.py doctor."
else
  echo "$missing missing. Hints:"
  echo "  podman: dnf install podman | apt install podman | brew install podman"
  echo "  cosign: github.com/sigstore/cosign -> releases"
  echo "  qemu:   dnf install qemu-system-x86 | apt install qemu-system-x86 | brew install qemu | winget install SoftwareFreedomConservancy.QEMU"
  echo "  /dev/fuse: pass the device through if you are inside a container/VM"
  exit 1
fi

#!/usr/bin/env bash
# Boot the Arch lab VM. Usage:
#   ./run.sh install   # boot from the ISO (first install / rescue)
#   ./run.sh           # boot from disk
set -euo pipefail
cd "$(dirname "$0")"

ISO=$(ls archlinux-*.iso 2>/dev/null | sort | tail -1 || true)
OVMF_CODE=${OVMF_CODE:-/usr/share/edk2/x64/OVMF_CODE.4m.fd}

args=(
    -enable-kvm -m 4G -smp 2 -cpu host
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE"
    -drive if=pflash,format=raw,file=ovmf_vars.fd
    -drive file=arch.qcow2,if=virtio,format=qcow2
    -nic user,model=virtio-net-pci,hostfwd=tcp::2222-:22   # ssh -p 2222 root@localhost
    -display default
)

if [ "${1:-}" = "install" ]; then
    [ -n "$ISO" ] || { echo "no archlinux-*.iso here — see README.md step 1" >&2; exit 1; }
    args+=(-cdrom "$ISO" -boot d)
fi

exec qemu-system-x86_64 "${args[@]}"

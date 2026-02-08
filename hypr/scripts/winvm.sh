#!/bin/bash
set -euo pipefail

VM_NAME="win10"
URI="qemu:///system"

# Start VM only if needed
STATE="$(virsh --connect "$URI" domstate "$VM_NAME" 2>/dev/null || true)"
if [[ "$STATE" != "running" ]]; then
    virsh --connect "$URI" start "$VM_NAME" >/dev/null
fi

# Attach viewer as soon as SPICE is ready
exec virt-viewer --connect "$URI" --attach --wait "$VM_NAME"

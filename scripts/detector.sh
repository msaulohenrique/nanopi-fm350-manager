#!/bin/bash
echo "=== FM350-GL Detector ==="
lsusb
mmcli -L || echo "ModemManager not ready"
echo "Ports: $(ls /dev/ttyUSB* /dev/cdc-wdm* 2>/dev/null || echo 'none')"
# Add AT testing logic here in real impl

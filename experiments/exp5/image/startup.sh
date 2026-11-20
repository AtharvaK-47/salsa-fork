#!/bin/bash
# startup.sh: run SALSA automatically at boot (called from boot.py, already as root).
# Copies results.json back to the boot partition, /boot/results/<date_time>/,
# so it can be read on the laptop by putting the SD card in it.

source /etc/profile.d/pynq_venv.sh
source /etc/profile.d/xrt_setup.sh

RUN=/home/xilinx/run
OUT=/boot/results/$(date +%Y-%m-%d_%H%M%S)
mkdir -p "$RUN" "$OUT"
cp /boot/salsa.bit /boot/salsa.hwh /boot/salsa.py "$RUN"/
cd "$RUN"

python3 salsa.py > /dev/null 2>&1
cp results.json "$OUT"/
sync                                   # flush to the SD card before anyone pulls it
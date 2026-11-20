#!/bin/sh
set -e
cd "$(dirname "$0")"
python3 make_hls_traces.py
if command -v vitis-run >/dev/null 2>&1; then
  vitis-run --mode hls --tcl run_hls.tcl
else
  vitis_hls -f run_hls.tcl
fi
python3 collect.py

#!/bin/bash
# Simulate with Verilator 5:   bash run.sh
set -e
verilator --binary --timing --timescale 1ns/1ps -Wno-fatal --top-module tb_top \
  salsa.sv salsa_segment_pull.sv tb_top.sv
./obj_dir/Vtb_top

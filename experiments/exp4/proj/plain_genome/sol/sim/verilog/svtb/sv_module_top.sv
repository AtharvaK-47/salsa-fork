//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2026.1 (64-bit)
//Tool Version Limit: 2026.06
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================

`ifndef SV_MODULE_TOP_SV
`define SV_MODULE_TOP_SV


`timescale 1ns/1ps


`include "uvm_macros.svh"
import uvm_pkg::*;
import file_agent_pkg::*;
import svr_pkg::*;
import fenwick_top_subsystem_pkg::*;
`include "fenwick_top_subsys_test_sequence_lib.sv"
`include "fenwick_top_test_lib.sv"


module sv_module_top;


    misc_interface              misc_if ( .clock(apatb_fenwick_top_top.AESL_clock), .reset(apatb_fenwick_top_top.AESL_reset) );
    assign apatb_fenwick_top_top.ap_start = misc_if.tb2dut_ap_start;
    assign misc_if.dut2tb_ap_done = apatb_fenwick_top_top.ap_done;
    assign misc_if.dut2tb_ap_ready = apatb_fenwick_top_top.ap_ready;
    initial begin
        uvm_config_db #(virtual misc_interface)::set(null, "uvm_test_top.top_env.*", "misc_if", misc_if);
    end


    svr_if #(32)  svr_n_if    (.clk  (apatb_fenwick_top_top.AESL_clock), .rst(apatb_fenwick_top_top.AESL_reset));
    assign apatb_fenwick_top_top.n = svr_n_if.data[31:0];
    assign svr_n_if.ready = svr_n_if.valid & misc_if.tb2dut_ap_start;
    initial begin
        uvm_config_db #( virtual svr_if#(32) )::set(null, "uvm_test_top.top_env.env_master_svr_n.*", "vif", svr_n_if);
    end


    initial begin
        run_test();
    end
endmodule
`endif

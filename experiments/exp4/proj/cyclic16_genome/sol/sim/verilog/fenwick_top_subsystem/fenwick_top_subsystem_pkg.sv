//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2026.1 (64-bit)
//Tool Version Limit: 2026.06
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`timescale 1ns/1ps 

`ifndef FENWICK_TOP_SUBSYSTEM_PKG__SV          
    `define FENWICK_TOP_SUBSYSTEM_PKG__SV      
                                                     
    package fenwick_top_subsystem_pkg;               
                                                     
        import uvm_pkg::*;                           
        import file_agent_pkg::*;                    
        import svr_pkg::*;
                                                     
        `include "uvm_macros.svh"                  
                                                     
        `include "fenwick_top_config.sv"           
        `include "fenwick_top_reference_model.sv"  
        `include "fenwick_top_scoreboard.sv"       
        `include "fenwick_top_subsystem_monitor.sv"
        `include "fenwick_top_virtual_sequencer.sv"
        `include "fenwick_top_pkg_sequence_lib.sv" 
        `include "fenwick_top_env.sv"              
                                                     
    endpackage                                       
                                                     
`endif                                               

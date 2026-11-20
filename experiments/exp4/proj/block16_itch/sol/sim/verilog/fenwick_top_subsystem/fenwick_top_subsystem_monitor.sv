//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2026.1 (64-bit)
//Tool Version Limit: 2026.06
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================

`ifndef FENWICK_TOP_SUBSYSTEM_MONITOR_SV
`define FENWICK_TOP_SUBSYSTEM_MONITOR_SV

`uvm_analysis_imp_decl(_svr_master_n)

class fenwick_top_subsystem_monitor extends uvm_component;

    fenwick_top_reference_model refm;
    fenwick_top_scoreboard scbd;

    `uvm_component_utils_begin(fenwick_top_subsystem_monitor)
    `uvm_component_utils_end

    uvm_analysis_imp_svr_master_n#(svr_pkg::svr_transfer#(32), fenwick_top_subsystem_monitor) svr_master_n_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(fenwick_top_reference_model)::get(this, "", "refm", refm))
            `uvm_fatal(this.get_full_name(), "No refm from high level")
        `uvm_info(this.get_full_name(), "get reference model by uvm_config_db", UVM_MEDIUM)
        scbd = fenwick_top_scoreboard::type_id::create("scbd", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
        svr_master_n_imp = new("svr_master_n_imp", this);
    endfunction

    virtual function void write_svr_master_n(svr_transfer#(32) tr);
        refm.write_svr_master_n(tr);
        scbd.write_svr_master_n(tr);
    endfunction
endclass
`endif

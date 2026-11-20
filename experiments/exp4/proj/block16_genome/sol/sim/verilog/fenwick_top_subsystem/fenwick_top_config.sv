//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2026.1 (64-bit)
//Tool Version Limit: 2026.06
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef FENWICK_TOP_CONFIG__SV                        
    `define FENWICK_TOP_CONFIG__SV                    
                                                            
    class fenwick_top_config extends uvm_object;            
                                                            
        int check_ena;                                      
        int cover_ena;                                      
        svr_pkg::svr_config port_n_cfg;

        `uvm_object_utils_begin(fenwick_top_config)         
        `uvm_field_object(port_n_cfg, UVM_DEFAULT)
        `uvm_field_int   (check_ena , UVM_DEFAULT)          
        `uvm_field_int   (cover_ena , UVM_DEFAULT)          
        `uvm_object_utils_end                               

        function new (string name = "fenwick_top_config");
            super.new(name);                                
            port_n_cfg = svr_pkg::svr_config::type_id::create("port_n_cfg");
        endfunction                                         
                                                            
    endclass                                                
                                                            
`endif                                                      

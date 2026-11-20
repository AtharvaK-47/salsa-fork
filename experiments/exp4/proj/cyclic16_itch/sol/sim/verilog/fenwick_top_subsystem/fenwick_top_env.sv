//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2026.1 (64-bit)
//Tool Version Limit: 2026.06
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef FENWICK_TOP_ENV__SV                                                                                   
    `define FENWICK_TOP_ENV__SV                                                                               
                                                                                                                    
                                                                                                                    
    class fenwick_top_env extends uvm_env;                                                                          
                                                                                                                    
        fenwick_top_virtual_sequencer fenwick_top_virtual_sqr;                                                      
        fenwick_top_config fenwick_top_cfg;                                                                         
                                                                                                                    
        svr_pkg::svr_env#(32) env_master_svr_n;
                                                                                                                    
        fenwick_top_reference_model   refm;                                                                         
                                                                                                                    
        fenwick_top_subsystem_monitor subsys_mon;                                                                   
                                                                                                                    
        `uvm_component_utils_begin(fenwick_top_env)                                                                 
        `uvm_field_object (env_master_svr_n,  UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_object (refm, UVM_DEFAULT | UVM_REFERENCE)                                                       
        `uvm_field_object (fenwick_top_virtual_sqr, UVM_DEFAULT | UVM_REFERENCE)                                    
        `uvm_field_object (fenwick_top_cfg        , UVM_DEFAULT)                                                    
        `uvm_component_utils_end                                                                                    
                                                                                                                    
        function new (string name = "fenwick_top_env", uvm_component parent = null);                              
            super.new(name, parent);                                                                                
        endfunction                                                                                                 
                                                                                                                    
        extern virtual function void build_phase(uvm_phase phase);                                                  
        extern virtual function void connect_phase(uvm_phase phase);                                                
        extern virtual task          run_phase(uvm_phase phase);                                                    
                                                                                                                    
    endclass                                                                                                        
                                                                                                                    
    function void fenwick_top_env::build_phase(uvm_phase phase);                                                    
        super.build_phase(phase);                                                                                   
        fenwick_top_cfg = fenwick_top_config::type_id::create("fenwick_top_cfg", this);                           
                                                                                                                    
        fenwick_top_cfg.port_n_cfg.svr_type = svr_pkg::SVR_MASTER ;
        env_master_svr_n  = svr_env#(32)::type_id::create("env_master_svr_n", this);
        uvm_config_db#(svr_pkg::svr_config)::set(this, "env_master_svr_n*", "cfg", fenwick_top_cfg.port_n_cfg);
        fenwick_top_cfg.port_n_cfg.prt_type = svr_pkg::AP_NONE;
        fenwick_top_cfg.port_n_cfg.is_active = svr_pkg::SVR_ACTIVE;
        fenwick_top_cfg.port_n_cfg.spec_cfg = svr_pkg::NORMAL;
        fenwick_top_cfg.port_n_cfg.reset_level = svr_pkg::RESET_LEVEL_HIGH;
 



        refm = fenwick_top_reference_model::type_id::create("refm", this);


        uvm_config_db#(fenwick_top_reference_model)::set(this, "*", "refm", refm);


        `uvm_info(this.get_full_name(), "set reference model by uvm_config_db", UVM_LOW)


        subsys_mon = fenwick_top_subsystem_monitor::type_id::create("subsys_mon", this);


        fenwick_top_virtual_sqr = fenwick_top_virtual_sequencer::type_id::create("fenwick_top_virtual_sqr", this);
        `uvm_info(this.get_full_name(), "build_phase done", UVM_LOW)
    endfunction


    function void fenwick_top_env::connect_phase(uvm_phase phase);
        super.connect_phase(phase);


        fenwick_top_virtual_sqr.svr_port_n_sqr = env_master_svr_n.m_agt.sqr;
        env_master_svr_n.m_agt.mon.item_collect_port.connect(subsys_mon.svr_master_n_imp);
 
        refm.fenwick_top_cfg = fenwick_top_cfg;
        `uvm_info(this.get_full_name(), "connect phase done", UVM_LOW)
    endfunction


    task fenwick_top_env::run_phase(uvm_phase phase);
        `uvm_info(this.get_full_name(), "fenwick_top_env is running", UVM_LOW)
    endtask


`endif

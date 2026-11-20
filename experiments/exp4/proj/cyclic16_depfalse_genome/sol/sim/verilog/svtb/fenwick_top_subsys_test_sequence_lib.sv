//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2026.1 (64-bit)
//Tool Version Limit: 2026.06
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef FENWICK_TOP_SUBSYS_TEST_SEQUENCE_LIB__SV                                              
    `define FENWICK_TOP_SUBSYS_TEST_SEQUENCE_LIB__SV                                          
                                                                                                    
    `define AUTOTB_TVIN_n_n  "../tv/cdatafile/c.fenwick_top.autotvin_n.dat" 
                                                                                                    
    `include "uvm_macros.svh"                                                                     
                                                                                                    
    // Delay kinds used in this test sequence                                                       
    typedef enum int {                                                                              
        TB_DELAY_NONE,                                                                              
        DELAY_DIRECTIO_BEFORE_FORCE,  // delay before force used in directio on s_axilite           
        DELAY_MAXI                    // delay for m_axi to make sure mem incr_rd_page_idx is called first
    } tb_delay_e;                                                                                   
                                                                                                    
    // Delay application task                                                                       
    task automatic tb_apply_delay(tb_delay_e kind);                                                 
        case (kind)                                                                                 
            TB_DELAY_NONE:                     ;         // no delay                                
            DELAY_DIRECTIO_BEFORE_FORCE: #0.001;                                                    
            DELAY_MAXI:                  #0.001;                                                    
            default:                           ;                                                    
        endcase                                                                                     
    endtask                                                                                         
                                                                                                    
    class fenwick_top_subsys_test_sequence_lib extends uvm_sequence;                                
                                                                                                    
        function new (string name = "fenwick_top_subsys_test_sequence_lib");                      
            super.new(name);                                                                        
            `uvm_info(this.get_full_name(), "new is called", UVM_LOW)                             
        endfunction                                                                                 
                                                                                                    
        `uvm_object_utils(fenwick_top_subsys_test_sequence_lib)                                     
        `uvm_declare_p_sequencer(fenwick_top_virtual_sequencer)                                     
                                                                                                    
        virtual task body();                                                                        
            uvm_phase starting_phase;                                                               
            virtual interface misc_interface misc_if;                                               
            fenwick_top_reference_model refm;                                                       
                                                                                                    
            string file_queue_n [$];                                                         
            integer bitwidth_queue_n [$];                                                    
                                                                                                               
            svr_pkg::svr_master_sequence#(32) svr_port_n_seq;            
            svr_pkg::svr_random_sequence#(32) svr_port_random_port_n_seq;


            if (!uvm_config_db#(fenwick_top_reference_model)::get(p_sequencer,"", "refm", refm))
                `uvm_fatal(this.get_full_name(), "No reference model")
            `uvm_info(this.get_full_name(), "get reference model by uvm_config_db", UVM_LOW)

            `uvm_info(this.get_full_name(), "body is called", UVM_LOW)
            starting_phase = this.get_starting_phase();
            if (starting_phase != null) begin
                `uvm_info(this.get_full_name(), "starting_phase not null", UVM_LOW)
                starting_phase.raise_objection(this);
            end
            else
                `uvm_info(this.get_full_name(), "starting_phase null" , UVM_LOW)

            misc_if = refm.misc_if;


            //phase_done.set_drain_time(this, 0ns);
            wait(refm.misc_if.reset === 0);
            ->refm.misc_if.initialed_evt;

            fork
                begin
                    fork
                        begin
                            string keystr_delay;
                            file_queue_n.push_back(`AUTOTB_TVIN_n_n);
                            bitwidth_queue_n.push_back(32);

                            `uvm_create_on(svr_port_n_seq, p_sequencer.svr_port_n_sqr);
                            svr_port_n_seq.misc_if = refm.misc_if;
                            svr_port_n_seq.ap_done  = refm.ap_done_for_nexttrans ;
                            svr_port_n_seq.ap_ready = refm.ap_ready_for_nexttrans;
                            svr_port_n_seq.finish   = refm.finish;
                            svr_port_n_seq.file_rd.config_file(file_queue_n, bitwidth_queue_n);
                            if( refm.fenwick_top_cfg.port_n_cfg.prt_type == AP_VLD ) wait(refm.misc_if.tb2dut_ap_start === 1'b1);
                            svr_port_n_seq.isusr_delay = svr_pkg::NO_DELAY;
                            `uvm_send(svr_port_n_seq);     
                        end                                               
                        begin
                            wait(svr_port_n_seq);
                            forever begin
                                wait(svr_port_n_seq.one_sect_read);
                                svr_port_n_seq.one_sect_read = 0;
                                -> refm.allsvr_input_done;
                            end
                        end
                        begin
                            int delay;
                            repeat(3) @(posedge refm.misc_if.clock);
                            for(int j=0; j<1; j++) begin
                                #0; refm.misc_if.tb2dut_ap_start = 1;
                                @(refm.dut2tb_ap_ready);
                                #0; refm.misc_if.tb2dut_ap_start = 0;
                                void'(std::randomize(delay) with { delay == 0; });
                                repeat(delay) @(posedge refm.misc_if.clock);
                            end
                        end
                        begin
                            int delay;
                            for(int j=0; j<1; j=j+refm.ap_done_cnt) begin
                                @refm.dut2tb_ap_done;
                                #0; refm.misc_if.tb2dut_ap_continue = 0;
                            end
                        end
                    join
                end

                begin
                    for(int j=0; j<1; j=j+refm.ap_done_cnt) @refm.ap_done_for_nexttrans;
                    `uvm_info(this.get_full_name(), "autotb finished", UVM_LOW)
                    -> refm.finish;
                    refm.misc_if.finished = 1;
                    @(posedge refm.misc_if.clock);
                    refm.misc_if.finished = 0;
                    @(posedge refm.misc_if.clock);
                    -> refm.misc_if.finished_evt;
                end
            join_any
            repeat(5) @(posedge refm.misc_if.clock); //5 cycles delay for finish stuff. 5 is haphazard value

            p_sequencer.svr_port_n_sqr.stop_sequences();
            disable fork;
                                                                                                    
            starting_phase.drop_objection(this);                                                    
                                                                                                    
        endtask                                                                                     
    endclass                                                                                        
                                                                                                    
`endif                                                                                              

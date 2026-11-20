set moduleName fenwick_top
set isTopModule 1
set isCombinational 0
set isDatapathOnly 0
set isPipelined 1
set isPipelined_legacy 1
set pipeline_type loop_auto_rewind
set FunctionProtocol ap_ctrl_hs
set restart_counter_num 0
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set hasInterrupt 0
set DLRegFirstOffset 0
set DLRegItemOffset 0
set svuvm_can_support 1
set cdfgNum 3
set C_modelName {fenwick_top}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
dict set ap_memory_interface_dict keys { MEM_WIDTH 16 MEM_SIZE 200000 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict kinds { MEM_WIDTH 8 MEM_SIZE 100000 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict vals { MEM_WIDTH 32 MEM_SIZE 400000 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict res { MEM_WIDTH 32 MEM_SIZE 400000 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 0 }
set C_modelArgList {
	{ keys int 16 regular {array 100000 { 1 3 } 1 1 }  }
	{ kinds int 8 regular {array 100000 { 1 3 } 1 1 }  }
	{ vals int 32 regular {array 100000 { 1 3 } 1 1 }  }
	{ res int 32 regular {array 100000 { 0 3 } 0 1 }  }
	{ n int 32 regular  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "keys", "interface" : "memory", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "kinds", "interface" : "memory", "bitwidth" : 8, "direction" : "READONLY"} , 
 	{ "Name" : "vals", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "res", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "n", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} ]}
# RTL Port declarations: 
set portNum 20
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ keys_address0 sc_out sc_lv 17 signal 0 } 
	{ keys_ce0 sc_out sc_logic 1 signal 0 } 
	{ keys_q0 sc_in sc_lv 16 signal 0 } 
	{ kinds_address0 sc_out sc_lv 17 signal 1 } 
	{ kinds_ce0 sc_out sc_logic 1 signal 1 } 
	{ kinds_q0 sc_in sc_lv 8 signal 1 } 
	{ vals_address0 sc_out sc_lv 17 signal 2 } 
	{ vals_ce0 sc_out sc_logic 1 signal 2 } 
	{ vals_q0 sc_in sc_lv 32 signal 2 } 
	{ res_address0 sc_out sc_lv 17 signal 3 } 
	{ res_ce0 sc_out sc_logic 1 signal 3 } 
	{ res_we0 sc_out sc_logic 1 signal 3 } 
	{ res_d0 sc_out sc_lv 32 signal 3 } 
	{ n sc_in sc_lv 32 signal 4 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "keys_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":17, "type": "signal", "bundle":{"name": "keys", "role": "address0" }} , 
 	{ "name": "keys_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "keys", "role": "ce0" }} , 
 	{ "name": "keys_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "keys", "role": "q0" }} , 
 	{ "name": "kinds_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":17, "type": "signal", "bundle":{"name": "kinds", "role": "address0" }} , 
 	{ "name": "kinds_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "kinds", "role": "ce0" }} , 
 	{ "name": "kinds_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "kinds", "role": "q0" }} , 
 	{ "name": "vals_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":17, "type": "signal", "bundle":{"name": "vals", "role": "address0" }} , 
 	{ "name": "vals_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "vals", "role": "ce0" }} , 
 	{ "name": "vals_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "vals", "role": "q0" }} , 
 	{ "name": "res_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":17, "type": "signal", "bundle":{"name": "res", "role": "address0" }} , 
 	{ "name": "res_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "res", "role": "ce0" }} , 
 	{ "name": "res_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "res", "role": "we0" }} , 
 	{ "name": "res_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "res", "role": "d0" }} , 
 	{ "name": "n", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "n", "role": "default" }}  ]}

set ArgLastReadFirstWriteLatency {
	fenwick_top {
		keys {Type I LastRead 0 FirstWrite -1}
		kinds {Type I LastRead 0 FirstWrite -1}
		vals {Type I LastRead 0 FirstWrite -1}
		res {Type O LastRead -1 FirstWrite 10}
		n {Type I LastRead 0 FirstWrite -1}
		fenwick_top_unsigned_short_const_unsigned_char_const_int_const_int_int_t_9 {Type IO LastRead -1 FirstWrite -1}
		fenwick_top_unsigned_short_const_unsigned_char_const_int_const_int_int_t_8 {Type IO LastRead -1 FirstWrite -1}
		fenwick_top_unsigned_short_const_unsigned_char_const_int_const_int_int_t_7 {Type IO LastRead -1 FirstWrite -1}
		fenwick_top_unsigned_short_const_unsigned_char_const_int_const_int_int_t_6 {Type IO LastRead -1 FirstWrite -1}
		fenwick_top_unsigned_short_const_unsigned_char_const_int_const_int_int_t_5 {Type IO LastRead -1 FirstWrite -1}
		fenwick_top_unsigned_short_const_unsigned_char_const_int_const_int_int_t_4 {Type IO LastRead -1 FirstWrite -1}
		fenwick_top_unsigned_short_const_unsigned_char_const_int_const_int_int_t_3 {Type IO LastRead -1 FirstWrite -1}
		fenwick_top_unsigned_short_const_unsigned_char_const_int_const_int_int_t_2 {Type IO LastRead -1 FirstWrite -1}
		fenwick_top_unsigned_short_const_unsigned_char_const_int_const_int_int_t_1 {Type IO LastRead -1 FirstWrite -1}
		fenwick_top_unsigned_short_const_unsigned_char_const_int_const_int_int_t {Type IO LastRead -1 FirstWrite -1}
		p_ZZ11fenwick_topPKtPKhPKiPiiE4tree_10 {Type IO LastRead -1 FirstWrite -1}
		p_ZZ11fenwick_topPKtPKhPKiPiiE4tree_11 {Type IO LastRead -1 FirstWrite -1}
		p_ZZ11fenwick_topPKtPKhPKiPiiE4tree_12 {Type IO LastRead -1 FirstWrite -1}
		p_ZZ11fenwick_topPKtPKhPKiPiiE4tree_13 {Type IO LastRead -1 FirstWrite -1}
		p_ZZ11fenwick_topPKtPKhPKiPiiE4tree_14 {Type IO LastRead -1 FirstWrite -1}
		p_ZZ11fenwick_topPKtPKhPKiPiiE4tree_15 {Type IO LastRead -1 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "36", "Max" : "3400002"}
	, {"Name" : "Interval", "Min" : "35", "Max" : "3400001"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	keys { ap_memory {  { keys_address0 mem_address 1 17 }  { keys_ce0 mem_ce 1 1 }  { keys_q0 mem_dout 0 16 } } }
	kinds { ap_memory {  { kinds_address0 mem_address 1 17 }  { kinds_ce0 mem_ce 1 1 }  { kinds_q0 mem_dout 0 8 } } }
	vals { ap_memory {  { vals_address0 mem_address 1 17 }  { vals_ce0 mem_ce 1 1 }  { vals_q0 mem_dout 0 32 } } }
	res { ap_memory {  { res_address0 mem_address 1 17 }  { res_ce0 mem_ce 1 1 }  { res_we0 mem_we 1 1 }  { res_d0 mem_din 1 32 } } }
	n { ap_none {  { n in_data 0 32 } } }
}

set maxi_interface_dict [dict create]

# RTL port scheduling information:
set fifoSchedulingInfoList { 
}

# RTL bus port read request latency information:
set busReadReqLatencyList { 
}

# RTL bus port write response latency information:
set busWriteResLatencyList { 
}

# RTL array port load latency information:
set memoryLoadLatencyList { 
}

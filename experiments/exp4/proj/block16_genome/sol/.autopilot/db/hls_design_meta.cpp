#include "hls_design_meta.h"
const Port_Property HLS_Design_Meta::port_props[]={
	Port_Property("ap_clk", 1, hls_in, -1, "", "", 1),
	Port_Property("ap_rst", 1, hls_in, -1, "", "", 1),
	Port_Property("ap_start", 1, hls_in, -1, "", "", 1),
	Port_Property("ap_done", 1, hls_out, -1, "", "", 1),
	Port_Property("ap_idle", 1, hls_out, -1, "", "", 1),
	Port_Property("ap_ready", 1, hls_out, -1, "", "", 1),
	Port_Property("keys_address0", 17, hls_out, 0, "ap_memory", "mem_address", 1),
	Port_Property("keys_ce0", 1, hls_out, 0, "ap_memory", "mem_ce", 1),
	Port_Property("keys_q0", 16, hls_in, 0, "ap_memory", "mem_dout", 1),
	Port_Property("kinds_address0", 17, hls_out, 1, "ap_memory", "mem_address", 1),
	Port_Property("kinds_ce0", 1, hls_out, 1, "ap_memory", "mem_ce", 1),
	Port_Property("kinds_q0", 8, hls_in, 1, "ap_memory", "mem_dout", 1),
	Port_Property("vals_address0", 17, hls_out, 2, "ap_memory", "mem_address", 1),
	Port_Property("vals_ce0", 1, hls_out, 2, "ap_memory", "mem_ce", 1),
	Port_Property("vals_q0", 32, hls_in, 2, "ap_memory", "mem_dout", 1),
	Port_Property("res_address0", 17, hls_out, 3, "ap_memory", "mem_address", 1),
	Port_Property("res_ce0", 1, hls_out, 3, "ap_memory", "mem_ce", 1),
	Port_Property("res_we0", 1, hls_out, 3, "ap_memory", "mem_we", 1),
	Port_Property("res_d0", 32, hls_out, 3, "ap_memory", "mem_din", 1),
	Port_Property("n", 32, hls_in, 4, "ap_none", "in_data", 1),
};
const char* HLS_Design_Meta::dut_name = "fenwick_top";

// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2026.1 (64-bit)
// Tool Version Limit: 2026.06
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
`timescale 1ns/1ps


`define AUTOTB_DUT      fenwick_top
`define AUTOTB_DUT_INST AESL_inst_fenwick_top
`define AUTOTB_TOP      apatb_fenwick_top_top
`define AUTOTB_LAT_RESULT_FILE "fenwick_top.result.lat.rb"
`define AUTOTB_PER_RESULT_TRANS_FILE "fenwick_top.performance.result.transaction.xml"
`define AUTOTB_TOP_INST AESL_inst_apatb_fenwick_top_top
`define AUTOTB_MAX_ALLOW_LATENCY  15000000
`define AUTOTB_CLOCK_PERIOD_DIV2 1.67

`define AESL_MEM_keys AESL_automem_keys
`define AESL_MEM_INST_keys mem_inst_keys
`define AESL_MEM_kinds AESL_automem_kinds
`define AESL_MEM_INST_kinds mem_inst_kinds
`define AESL_MEM_vals AESL_automem_vals
`define AESL_MEM_INST_vals mem_inst_vals
`define AESL_MEM_res AESL_automem_res
`define AESL_MEM_INST_res mem_inst_res
`define AESL_DEPTH_n 1
`define AUTOTB_TVIN_keys  "../tv/cdatafile/c.fenwick_top.autotvin_keys.dat"
`define AUTOTB_TVIN_kinds  "../tv/cdatafile/c.fenwick_top.autotvin_kinds.dat"
`define AUTOTB_TVIN_vals  "../tv/cdatafile/c.fenwick_top.autotvin_vals.dat"
`define AUTOTB_TVIN_res  "../tv/cdatafile/c.fenwick_top.autotvin_res.dat"
`define AUTOTB_TVIN_n  "../tv/cdatafile/c.fenwick_top.autotvin_n.dat"
`define AUTOTB_TVIN_keys_out_wrapc  "../tv/rtldatafile/rtl.fenwick_top.autotvin_keys.dat"
`define AUTOTB_TVIN_kinds_out_wrapc  "../tv/rtldatafile/rtl.fenwick_top.autotvin_kinds.dat"
`define AUTOTB_TVIN_vals_out_wrapc  "../tv/rtldatafile/rtl.fenwick_top.autotvin_vals.dat"
`define AUTOTB_TVIN_res_out_wrapc  "../tv/rtldatafile/rtl.fenwick_top.autotvin_res.dat"
`define AUTOTB_TVIN_n_out_wrapc  "../tv/rtldatafile/rtl.fenwick_top.autotvin_n.dat"
`define AUTOTB_TVOUT_res  "../tv/cdatafile/c.fenwick_top.autotvout_res.dat"
`define AUTOTB_TVOUT_res_out_wrapc  "../tv/rtldatafile/rtl.fenwick_top.autotvout_res.dat"
module `AUTOTB_TOP;

parameter AUTOTB_TRANSACTION_NUM = 1;
parameter PROGRESS_TIMEOUT = 10000000;
parameter LATENCY_ESTIMATION = 3400002;
parameter LENGTH_keys = 100000;
parameter LENGTH_kinds = 100000;
parameter LENGTH_n = 1;
parameter LENGTH_res = 100000;
parameter LENGTH_vals = 100000;

reg AESL_clock;
reg rst;
reg dut_rst;
reg start;
reg ce;
reg tb_continue;
wire AESL_start;
wire AESL_reset;
wire AESL_ce;
wire AESL_ready;
wire AESL_idle;
wire AESL_continue;
wire AESL_done;
reg AESL_done_delay = 0;
reg AESL_done_delay2 = 0;
reg AESL_ready_delay = 0;
wire ready;
wire ready_wire;
wire ap_start;
wire ap_done;
wire ap_idle;
wire ap_ready;
wire [16 : 0] keys_address0;
wire  keys_ce0;
wire [15 : 0] keys_q0;
wire [16 : 0] kinds_address0;
wire  kinds_ce0;
wire [7 : 0] kinds_q0;
wire [16 : 0] vals_address0;
wire  vals_ce0;
wire [31 : 0] vals_q0;
wire [16 : 0] res_address0;
wire  res_ce0;
wire  res_we0;
wire [31 : 0] res_d0;
wire [31 : 0] n;
integer done_cnt = 0;
integer AESL_ready_cnt = 0;
integer ready_cnt = 0;
reg ready_initial;
reg ready_initial_n;
reg ready_last_n;
reg ready_delay_last_n;
reg done_delay_last_n;
reg interface_done = 0;


wire all_finish;
wire ap_clk;
wire ap_rst;
wire ap_rst_n;

`AUTOTB_DUT `AUTOTB_DUT_INST(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst),
    .ap_start(ap_start),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .ap_ready(ap_ready),
    .keys_address0(keys_address0),
    .keys_ce0(keys_ce0),
    .keys_q0(keys_q0),
    .kinds_address0(kinds_address0),
    .kinds_ce0(kinds_ce0),
    .kinds_q0(kinds_q0),
    .vals_address0(vals_address0),
    .vals_ce0(vals_ce0),
    .vals_q0(vals_q0),
    .res_address0(res_address0),
    .res_ce0(res_ce0),
    .res_we0(res_we0),
    .res_d0(res_d0),
    .n(n));
assign ap_clk = AESL_clock;
assign ap_rst = AESL_reset;
assign ap_rst_n = ~AESL_reset;
assign AESL_reset = dut_rst;
assign AESL_start = svtb_top.misc_if.tb2dut_ap_start;
assign AESL_ready = svtb_top.misc_if.dut2tb_ap_ready;
assign AESL_done  = svtb_top.misc_if.dut2tb_ap_done;
assign all_finish = svtb_top.misc_if.finished;
initial begin : initial_process
    integer proc_rand;
    rst = 1;
    # 100;
    repeat(0+3) @ (posedge AESL_clock);
    # 0.1;
    rst = 0;
end
initial begin : initial_process_for_dut_rst
    integer proc_rand;
    dut_rst = 1;
    # 100;
    repeat(3) @ (posedge AESL_clock);
    # 0.1;
    dut_rst = 0;
end
initial begin
    AESL_clock = 0;
    forever #`AUTOTB_CLOCK_PERIOD_DIV2 AESL_clock = ~AESL_clock;
end

    sv_module_top svtb_top();
//------------------------arraykeys Instantiation--------------

// The input and output of arraykeys
wire    arraykeys_ce0, arraykeys_ce1;
wire [2 - 1 : 0]    arraykeys_we0, arraykeys_we1;
wire    [16 : 0]    arraykeys_address0, arraykeys_address1;
wire    [15 : 0]    arraykeys_din0, arraykeys_din1;
wire    [15 : 0]    arraykeys_dout0, arraykeys_dout1;
wire    arraykeys_ready;
wire    arraykeys_done;

`AESL_MEM_keys `AESL_MEM_INST_keys(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arraykeys_ce0),
    .we0        (arraykeys_we0),
    .address0   (arraykeys_address0),
    .din0       (arraykeys_din0),
    .dout0      (arraykeys_dout0),
    .ce1        (arraykeys_ce1),
    .we1        (arraykeys_we1),
    .address1   (arraykeys_address1),
    .din1       (arraykeys_din1),
    .dout1      (arraykeys_dout1),
    .ready      (arraykeys_ready),
    .done    (arraykeys_done)
);

// Assignment between dut and arraykeys
assign arraykeys_address0 = keys_address0;
assign arraykeys_ce0 = keys_ce0;
assign keys_q0 = arraykeys_dout0;
assign arraykeys_we0 = 0;
assign arraykeys_din0 = 0;
assign arraykeys_we1 = 0;
assign arraykeys_din1 = 0;
assign arraykeys_ready=    ready;
assign arraykeys_done = 0;

event keys_reshape_ap_done_evt;
event keys_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_keys.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_keys.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_keys.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_keys.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arraykinds Instantiation--------------

// The input and output of arraykinds
wire    arraykinds_ce0, arraykinds_ce1;
wire [1 - 1 : 0]    arraykinds_we0, arraykinds_we1;
wire    [16 : 0]    arraykinds_address0, arraykinds_address1;
wire    [7 : 0]    arraykinds_din0, arraykinds_din1;
wire    [7 : 0]    arraykinds_dout0, arraykinds_dout1;
wire    arraykinds_ready;
wire    arraykinds_done;

`AESL_MEM_kinds `AESL_MEM_INST_kinds(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arraykinds_ce0),
    .we0        (arraykinds_we0),
    .address0   (arraykinds_address0),
    .din0       (arraykinds_din0),
    .dout0      (arraykinds_dout0),
    .ce1        (arraykinds_ce1),
    .we1        (arraykinds_we1),
    .address1   (arraykinds_address1),
    .din1       (arraykinds_din1),
    .dout1      (arraykinds_dout1),
    .ready      (arraykinds_ready),
    .done    (arraykinds_done)
);

// Assignment between dut and arraykinds
assign arraykinds_address0 = kinds_address0;
assign arraykinds_ce0 = kinds_ce0;
assign kinds_q0 = arraykinds_dout0;
assign arraykinds_we0 = 0;
assign arraykinds_din0 = 0;
assign arraykinds_we1 = 0;
assign arraykinds_din1 = 0;
assign arraykinds_ready=    ready;
assign arraykinds_done = 0;

event kinds_reshape_ap_done_evt;
event kinds_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_kinds.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_kinds.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_kinds.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_kinds.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayvals Instantiation--------------

// The input and output of arrayvals
wire    arrayvals_ce0, arrayvals_ce1;
wire [4 - 1 : 0]    arrayvals_we0, arrayvals_we1;
wire    [16 : 0]    arrayvals_address0, arrayvals_address1;
wire    [31 : 0]    arrayvals_din0, arrayvals_din1;
wire    [31 : 0]    arrayvals_dout0, arrayvals_dout1;
wire    arrayvals_ready;
wire    arrayvals_done;

`AESL_MEM_vals `AESL_MEM_INST_vals(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayvals_ce0),
    .we0        (arrayvals_we0),
    .address0   (arrayvals_address0),
    .din0       (arrayvals_din0),
    .dout0      (arrayvals_dout0),
    .ce1        (arrayvals_ce1),
    .we1        (arrayvals_we1),
    .address1   (arrayvals_address1),
    .din1       (arrayvals_din1),
    .dout1      (arrayvals_dout1),
    .ready      (arrayvals_ready),
    .done    (arrayvals_done)
);

// Assignment between dut and arrayvals
assign arrayvals_address0 = vals_address0;
assign arrayvals_ce0 = vals_ce0;
assign vals_q0 = arrayvals_dout0;
assign arrayvals_we0 = 0;
assign arrayvals_din0 = 0;
assign arrayvals_we1 = 0;
assign arrayvals_din1 = 0;
assign arrayvals_ready=    ready;
assign arrayvals_done = 0;

event vals_reshape_ap_done_evt;
event vals_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_vals.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_vals.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_vals.dut2tb_ap_ready = svtb_top.misc_if.dut2tb_ap_ready_evt;
     `AESL_MEM_INST_vals.dut2tb_ap_done = svtb_top.misc_if.dut2tb_ap_ready_evt;
end
//------------------------arrayres Instantiation--------------

// The input and output of arrayres
wire    arrayres_ce0, arrayres_ce1;
wire [4 - 1 : 0]    arrayres_we0, arrayres_we1;
wire    [16 : 0]    arrayres_address0, arrayres_address1;
wire    [31 : 0]    arrayres_din0, arrayres_din1;
wire    [31 : 0]    arrayres_dout0, arrayres_dout1;
wire    arrayres_ready;
wire    arrayres_done;

`AESL_MEM_res `AESL_MEM_INST_res(
    .clk        (AESL_clock),
    .rst        (AESL_reset),
    .ce0        (arrayres_ce0),
    .we0        (arrayres_we0),
    .address0   (arrayres_address0),
    .din0       (arrayres_din0),
    .dout0      (arrayres_dout0),
    .ce1        (arrayres_ce1),
    .we1        (arrayres_we1),
    .address1   (arrayres_address1),
    .din1       (arrayres_din1),
    .dout1      (arrayres_dout1),
    .ready      (arrayres_ready),
    .done    (arrayres_done)
);

// Assignment between dut and arrayres
assign arrayres_address0 = res_address0;
assign arrayres_ce0 = res_ce0;
assign arrayres_we0[0] = res_we0;
assign arrayres_we0[1] = res_we0;
assign arrayres_we0[2] = res_we0;
assign arrayres_we0[3] = res_we0;
assign arrayres_din0 = res_d0;
assign arrayres_we1 = 0;
assign arrayres_din1 = 0;
assign arrayres_ready= ready_initial | arrayres_done;
assign arrayres_done =    AESL_done_delay;

event res_reshape_ap_done_evt;
event res_reshape_ap_ready_evt;
initial begin
     `AESL_MEM_INST_res.initialed       = svtb_top.misc_if.initialed_evt  ;
     `AESL_MEM_INST_res.finished        = svtb_top.misc_if.finished_evt   ;
     `AESL_MEM_INST_res.dut2tb_ap_done  = svtb_top.misc_if.dut2tb_ap_done_evt;
     `AESL_MEM_INST_res.dut2tb_ap_ready = res_reshape_ap_ready_evt;
end
initial begin
    forever begin
        @svtb_top.misc_if.dut2tb_ap_done_evt;
        #0;
        -> res_reshape_ap_ready_evt;
    end
end

////////////////////////////////////////////
// progress and performance
////////////////////////////////////////////

task wait_start();
    while (~AESL_start) begin
        @ (posedge AESL_clock);
    end
endtask

reg [31:0] clk_cnt = 0;
reg AESL_ready_p1;
reg AESL_start_p1;

always @ (posedge AESL_clock) begin
    if (AESL_reset == 1) begin
        clk_cnt <= 32'h0;
        AESL_ready_p1 <= 1'b0;
        AESL_start_p1 <= 1'b0;
    end
    else begin
        clk_cnt <= clk_cnt + 1;
        AESL_ready_p1 <= AESL_ready;
        AESL_start_p1 <= AESL_start;
    end
end

reg [31:0] start_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] start_cnt;
reg [31:0] ready_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] ap_ready_cnt;
reg [31:0] finish_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] finish_cnt;
reg [31:0] lat_total;
event report_progress;

always @(posedge AESL_clock)
begin
    if (finish_cnt == AUTOTB_TRANSACTION_NUM - 1 && AESL_done == 1'b1)
        lat_total = clk_cnt - start_timestamp[0];
end

initial begin
    start_cnt = 0;
    finish_cnt = 0;
    ap_ready_cnt = 0;
    wait (AESL_reset == 0);
    wait_start();
    start_timestamp[start_cnt] = clk_cnt;
    start_cnt = start_cnt + 1;
    if (AESL_done) begin
        finish_timestamp[finish_cnt] = clk_cnt;
        finish_cnt = finish_cnt + 1;
    end
    -> report_progress;
    forever begin
        @ (posedge AESL_clock);
        if (start_cnt < AUTOTB_TRANSACTION_NUM) begin
            if ((AESL_start && AESL_ready_p1)||(AESL_start && ~AESL_start_p1)) begin
                start_timestamp[start_cnt] = clk_cnt;
                start_cnt = start_cnt + 1;
            end
        end
        if (ap_ready_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_start_p1 && AESL_ready_p1) begin
                ready_timestamp[ap_ready_cnt] = clk_cnt;
                ap_ready_cnt = ap_ready_cnt + 1;
            end
        end
        if (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_done) begin
                finish_timestamp[finish_cnt] = clk_cnt;
                finish_cnt = finish_cnt + 1;
            end
        end
        -> report_progress;
    end
end

reg [31:0] progress_timeout;

initial begin : simulation_progress
    real intra_progress;
    wait (AESL_reset == 0);
    progress_timeout = PROGRESS_TIMEOUT;
    $display("////////////////////////////////////////////////////////////////////////////////////");
    $display("// Inter-Transaction Progress: Completed Transaction / Total Transaction");
    $display("// Intra-Transaction Progress: Measured Latency / Latency Estimation * 100%%");
    $display("//");
    $display("// RTL Simulation : \"Inter-Transaction Progress\" [\"Intra-Transaction Progress\"] @ \"Simulation Time\"");
    $display("////////////////////////////////////////////////////////////////////////////////////");
    print_progress();
    while (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
        @ (report_progress);
        if (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_done) begin
                print_progress();
                progress_timeout = PROGRESS_TIMEOUT;
            end else begin
                if (progress_timeout == 0) begin
                    print_progress();
                    progress_timeout = PROGRESS_TIMEOUT;
                end else begin
                    progress_timeout = progress_timeout - 1;
                end
            end
        end
    end
    print_progress();
    $display("////////////////////////////////////////////////////////////////////////////////////");
    calculate_performance();
end

task get_intra_progress(output real intra_progress);
    begin
        if (start_cnt > finish_cnt) begin
            intra_progress = clk_cnt - start_timestamp[finish_cnt];
        end else if(finish_cnt > 0) begin
            intra_progress = LATENCY_ESTIMATION;
        end else begin
            intra_progress = 0;
        end
        intra_progress = intra_progress / LATENCY_ESTIMATION;
    end
endtask

task print_progress();
    real intra_progress;
    begin
        if (LATENCY_ESTIMATION > 0) begin
            get_intra_progress(intra_progress);
            $display("// RTL Simulation : %0d / %0d [%2.2f%%] @ \"%0t\"", finish_cnt, AUTOTB_TRANSACTION_NUM, intra_progress * 100, $time);
        end else begin
            $display("// RTL Simulation : %0d / %0d [n/a] @ \"%0t\"", finish_cnt, AUTOTB_TRANSACTION_NUM, $time);
        end
    end
endtask

task calculate_performance();
    integer i;
    integer fp;
    reg [31:0] latency [0:AUTOTB_TRANSACTION_NUM - 1];
    reg [31:0] latency_min;
    reg [31:0] latency_max;
    reg [31:0] latency_total;
    reg [31:0] latency_average;
    reg [31:0] interval [0:AUTOTB_TRANSACTION_NUM - 2];
    reg [31:0] interval_min;
    reg [31:0] interval_max;
    reg [31:0] interval_total;
    reg [31:0] interval_average;
    reg [31:0] total_execute_time;
    begin
        latency_min = -1;
        latency_max = 0;
        latency_total = 0;
        interval_min = -1;
        interval_max = 0;
        interval_total = 0;
        total_execute_time = lat_total;

        for (i = 0; i < AUTOTB_TRANSACTION_NUM; i = i + 1) begin
            // calculate latency
            latency[i] = finish_timestamp[i] - start_timestamp[i];
            if (latency[i] > latency_max) latency_max = latency[i];
            if (latency[i] < latency_min) latency_min = latency[i];
            latency_total = latency_total + latency[i];
            // calculate interval
            if (AUTOTB_TRANSACTION_NUM == 1) begin
                interval[i] = 0;
                interval_max = 0;
                interval_min = 0;
                interval_total = 0;
            end else if (i < AUTOTB_TRANSACTION_NUM - 1) begin
                interval[i] = start_timestamp[i + 1] - start_timestamp[i];
                if (interval[i] > interval_max) interval_max = interval[i];
                if (interval[i] < interval_min) interval_min = interval[i];
                interval_total = interval_total + interval[i];
            end
        end

        latency_average = latency_total / AUTOTB_TRANSACTION_NUM;
        if (AUTOTB_TRANSACTION_NUM == 1) begin
            interval_average = 0;
        end else begin
            interval_average = interval_total / (AUTOTB_TRANSACTION_NUM - 1);
        end

        fp = $fopen(`AUTOTB_LAT_RESULT_FILE, "w");

        $fdisplay(fp, "$MAX_LATENCY = \"%0d\"", latency_max);
        $fdisplay(fp, "$MIN_LATENCY = \"%0d\"", latency_min);
        $fdisplay(fp, "$AVER_LATENCY = \"%0d\"", latency_average);
        $fdisplay(fp, "$MAX_THROUGHPUT = \"%0d\"", interval_max);
        $fdisplay(fp, "$MIN_THROUGHPUT = \"%0d\"", interval_min);
        $fdisplay(fp, "$AVER_THROUGHPUT = \"%0d\"", interval_average);
        $fdisplay(fp, "$TOTAL_EXECUTE_TIME = \"%0d\"", total_execute_time);

        $fclose(fp);

        fp = $fopen(`AUTOTB_PER_RESULT_TRANS_FILE, "w");

        $fdisplay(fp, "%20s%16s%16s", "", "latency", "interval");
        if (AUTOTB_TRANSACTION_NUM == 1) begin
            i = 0;
            $fdisplay(fp, "transaction%8d:%16d%16d", i, latency[i], interval[i]);
        end else begin
            for (i = 0; i < AUTOTB_TRANSACTION_NUM; i = i + 1) begin
                if (i < AUTOTB_TRANSACTION_NUM - 1) begin
                    $fdisplay(fp, "transaction%8d:%16d%16d", i, latency[i], interval[i]);
                end else begin
                    $fdisplay(fp, "transaction%8d:%16d               x", i, latency[i]);
                end
            end
        end

        $fclose(fp);
    end
endtask


////////////////////////////////////////////
// Dependence Check
////////////////////////////////////////////

`ifndef POST_SYN

`endif
///////////////////////////////////////////////////////
// dataflow status monitor
///////////////////////////////////////////////////////
dataflow_monitor U_dataflow_monitor(
    .clock(AESL_clock),
    .reset(rst),
    .finish(all_finish));

`include "fifo_para.vh"
endmodule

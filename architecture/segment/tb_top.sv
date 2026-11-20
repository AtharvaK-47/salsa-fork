`timescale 1ns/1ps
module tb_top;
  import salsa_pkg::*;
  localparam int N = 1 << W;
  logic aclk = 0, aresetn = 0;
  always #5 aclk = ~aclk;
  logic [63:0] s_tdata = 0; logic s_tvalid = 0, s_tready;
  logic [63:0] m_tdata; logic m_tvalid, m_tready = 0, m_tlast;
  logic [7:0] awaddr = 0, araddr = 0; logic awvalid = 0, wvalid = 0, arvalid = 0;
  logic [31:0] wdata = 0, rdata; logic awready, wready, bvalid, arready, rvalid;
  logic [1:0] bresp, rresp;

  salsa #(.DEPTH(16)) dut (
    .aclk, .aresetn,
    .s_axis_tdata(s_tdata), .s_axis_tvalid(s_tvalid), .s_axis_tready(s_tready), .s_axis_tlast(1'b0),
    .m_axis_tdata(m_tdata), .m_axis_tvalid(m_tvalid), .m_axis_tready(m_tready), .m_axis_tlast(m_tlast),
    .s_axi_awaddr(awaddr), .s_axi_awprot(3'b0), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
    .s_axi_wdata(wdata), .s_axi_wstrb(4'hf), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
    .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(1'b1),
    .s_axi_araddr(araddr), .s_axi_arprot(3'b0), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
    .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(1'b1));

  logic [31:0] gold [1:2*N-1];
  task automatic g_update(int i, logic [31:0] v);
    int n; n = N + i; gold[n] = v; n >>= 1;
    while (n >= 1) begin gold[n] = combine(gold[2*n], gold[2*n+1]); n >>= 1; end
  endtask
  function automatic logic [31:0] g_query(int l, int r);
    logic [31:0] acc; acc = ID; l += N; r += N;
    while (l < r) begin
      if (l & 1) begin acc = combine(acc, gold[l]); l++; end
      if (r & 1) begin r--; acc = combine(acc, gold[r]); end
      l >>= 1; r >>= 1;
    end
    return acc;
  endfunction

  task automatic axil_write(logic [7:0] a, logic [31:0] d);
    awaddr = a; wdata = d; awvalid = 1; wvalid = 1;
    do @(posedge aclk); while (!(awready && wready));
    #1 awvalid = 0; wvalid = 0;
    do @(posedge aclk); while (!bvalid);
    #1;
  endtask
  task automatic axil_read(logic [7:0] a, output logic [31:0] d);
    araddr = a; arvalid = 1;
    do @(posedge aclk); while (!arready);
    #1 arvalid = 0;
    while (!rvalid) @(posedge aclk);
    d = rdata; #1;
  endtask

  localparam int NOPS = 30000;
  logic [63:0] req [NOPS]; logic [63:0] exp_w [NOPS];
  int nexp = 0, ngot = 0, errors = 0, lasts = 0;

  always @(posedge aclk)
    if (m_tvalid && m_tready) begin
      if (ngot < nexp && m_tdata !== exp_w[ngot]) begin
        errors++;
        if (errors <= 10) $display("MISMATCH %0d: got %h expected %h", ngot, m_tdata, exp_w[ngot]);
      end
      if (m_tlast) begin lasts++; if (ngot != NOPS - 1) begin errors++; $display("tlast at %0d", ngot); end end
      ngot++;
    end

  always @(posedge aclk) m_tready <= ($urandom_range(99) < 70);

  initial begin
    logic [31:0] st, rl, rq, rs;
    int mid; mid = N / 2;
    for (int n = 1; n < 2*N; n++) gold[n] = ID;
    for (int t = 0; t < NOPS; t++) begin
      word_t w; int u; u = $urandom_range(99);
      w.seq = SEQW'(t);
      mid = mid + $urandom_range(4) - 2; if (mid < 64) mid = 64; if (mid > N - 65) mid = N - 65;
      if (u < 60) begin
        w.op = OP_UPDATE; w.key = W'(mid + $urandom_range(32) - 16);
        w.value = ($urandom_range(3) == 0) ? ID : 32'($urandom_range(999));
        g_update(int'(w.key), w.value); exp_w[t] = w;
      end else begin
        int l, r; l = mid - $urandom_range(40, 1); r = (u < 90) ? mid + $urandom_range(40, 1) : N;
        if (u >= 90) l = 0;
        w.op = OP_QUERY; w.key = W'(l); w.value = 32'(r);
        exp_w[t] = w; exp_w[t][31:0] = g_query(l, r);
      end
      req[t] = w;
    end
    nexp = NOPS;
    repeat (5) @(posedge aclk); #1 aresetn = 1;
    do axil_read(8'h04, st); while (!st[1]);
    axil_write(8'h08, NOPS);
    axil_write(8'h00, 1);
    for (int t = 0; t < NOPS; ) begin
      if ($urandom_range(99) < 85) begin
        logic rdy;
        s_tdata = req[t]; s_tvalid = 1;
        #1 rdy = s_tready;
        @(posedge aclk);
        if (rdy) t++;
        #1;
      end else begin
        s_tvalid = 0; @(posedge aclk); #1;
      end
    end
    s_tvalid = 0;
    while (ngot < NOPS) @(posedge aclk);
    repeat (5) @(posedge aclk);
    axil_read(8'h04, st); axil_read(8'h08, rl); axil_read(8'h10, rq); axil_read(8'h14, rs);
    $display("%s tree via AXI: %0d results, %0d errors, tlast %0d, done=%0d run_len=%0d req=%0d res=%0d",
             MIN ? "min" : "max", ngot, errors, lasts, st[0], rl, rq, rs);
    if (errors == 0 && lasts == 1 && st[0] && rq == NOPS && rs == NOPS) $display("PASS"); else $display("FAIL");
    $finish;
  end
endmodule
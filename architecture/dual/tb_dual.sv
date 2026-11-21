`timescale 1ns/1ps
module tb_dual;
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

  int signed cov [N];
  function automatic logic [31:0] csum(int i);
    logic [31:0] s; s = 0;
    for (int j = 1; j <= i; j++) s += 32'(cov[j]);
    return s;
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

  localparam int NR = 12000;
  logic [63:0] req [2*NR]; logic [63:0] exp_w [2*NR]; logic isq [2*NR];
  int nw = 0, ngot = 0, errors = 0, lasts = 0, nq = 0, rq_ok = 0;
  logic [31:0] got [2*NR];

  always @(posedge aclk)
    if (m_tvalid && m_tready) begin
      got[ngot] = m_tdata[31:0];
      if (m_tdata !== exp_w[ngot]) begin
        errors++;
        if (errors <= 10) $display("MISMATCH word %0d: got %h expected %h", ngot, m_tdata, exp_w[ngot]);
      end
      if (m_tlast) lasts++;
      ngot++;
    end
  always @(posedge aclk) m_tready <= ($urandom_range(99) < 70);

  task automatic push_word(logic [1:0] op, int key, logic [31:0] val, logic q);
    word_t w;
    w.op = op; w.seq = SEQW'(nw); w.key = W'(key); w.value = val;
    req[nw] = w; isq[nw] = q;
    exp_w[nw] = w;
    if (q) exp_w[nw][31:0] = csum(key);
    nw++;
  endtask

  int ql [NR], qr [NR], qw [NR]; logic [31:0] qg [NR];
  initial begin
    logic [31:0] st, rl, rqc, rsc;
    int center; center = 30000;
    for (int i = 0; i < N; i++) cov[i] = 0;
    for (int t = 0; t < NR; t++) begin
      int u; u = $urandom_range(99);
      center = center + $urandom_range(200) - 100; if (center < 1000) center = 1000; if (center > N - 1000) center = N - 1000;
      if (u < 65) begin
        int l, r, x;
        l = center + $urandom_range(300) - 150; r = l + $urandom_range(600);
        x = ($urandom_range(9) == 0) ? -1 : int'($urandom_range(3)) + 1;
        if (r > N - 1) r = N - 1;
        for (int j = l; j <= r; j++) cov[j] += x;
        push_word(OP_UPDATE, l, 32'(x), 0);
        if (r + 1 <= N - 1) push_word(OP_UPDATE, r + 1, 32'(-x), 0);
      end else begin
        int l, r;
        l = center + $urandom_range(400) - 200; r = l + $urandom_range(500);
        if ($urandom_range(19) == 0) l = 1;
        if (r > N - 1) r = N - 1;
        ql[nq] = l; qr[nq] = r;
        qg[nq] = 0; for (int p = l; p <= r; p++) qg[nq] += 32'(cov[p]);
        qw[nq] = nw;
        push_word(OP_QUERY, r, 0, 1);
        if (l > 1) push_word(OP_QUERY, l - 1, 0, 1);
        nq++;
      end
    end
    repeat (5) @(posedge aclk); #1 aresetn = 1;
    repeat (3) @(posedge aclk); #1;
    axil_write(8'h08, nw);
    axil_write(8'h00, 1);
    for (int t = 0; t < nw; ) begin
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
    while (ngot < nw) @(posedge aclk);
    repeat (5) @(posedge aclk);
    for (int k = 0; k < nq; k++) begin
      logic [31:0] hw, gold;
      int j; j = qw[k];
      hw = got[j] - ((ql[k] > 1) ? got[j + 1] : 32'd0);
      gold = qg[k];
      if (hw == gold) rq_ok++;
    end
    axil_read(8'h04, st); axil_read(8'h08, rl); axil_read(8'h10, rqc); axil_read(8'h14, rsc);
    $display("dual Fenwick via AXI: %0d endpoint words, %0d errors; %0d/%0d range sums correct; tlast %0d, done=%0d req=%0d res=%0d",
             nw, errors, rq_ok, nq, lasts, st[0], rqc, rsc);
    if (errors == 0 && rq_ok == nq && lasts == 1 && st[0] && rqc == nw && rsc == nw) $display("PASS"); else $display("FAIL");
    $finish;
  end
endmodule

package salsa_pkg;
  localparam int W    = 16, K = 12;
  localparam int HW   = W - K;
  localparam int B    = 1 << HW;
  localparam int R    = B - 1;
  localparam int NL   = W + 1;
  localparam int LW   = $clog2(NL);
  localparam int SEQW = 64 - 2 - W - 32;
  localparam bit MIN  = 1'b0;
  localparam logic [1:0] OP_QUERY = 0, OP_UPDATE = 2;
  typedef struct packed {
    logic [1:0]      op;
    logic [SEQW-1:0] seq;
    logic [W-1:0]    key;
    logic [31:0]     value;
  } word_t;
  function automatic logic [31:0] combine(input logic [31:0] x, input logic [31:0] y);
    if (MIN) return (x < y) ? x : y;
    else     return (x > y) ? x : y;
  endfunction
  localparam logic [31:0] ID = MIN ? '1 : '0;
endpackage

module salsa_datapath import salsa_pkg::*; (
  input  logic               clk, rst,
  input  logic               in_valid,
  input  word_t              in_word,
  output logic               out_valid,
  output word_t              out_word,
  output logic [B-1:0][31:0] bank_stores,
  output logic [31:0]        root_stores,
  output logic               init_done
);
`ifndef SYNTHESIS
  initial begin
    if (HW < 2)    $fatal(1, "need W - K >= 2 (at least 4 banks)");
    if (SEQW < 1)  $fatal(1, "key too wide for the 64-bit word");
  end
`endif

  localparam int KW = $clog2(NL);

  function automatic logic [B-1:0][31:0] rot(input logic [B-1:0][31:0] v, input logic [HW-1:0] s);
    logic [B-1:0][31:0] w;
    for (int i = 0; i < HW; i++) begin
      for (int l = 0; l < B; l++) w[l] = s[i] ? v[(l + (1 << i)) % B] : v[l];
      v = w;
    end
    return v;
  endfunction

  logic iss_valid, iss_update; logic [31:0] data;
  logic [NL-1:0][1:0][W:0] cand; logic [NL-1:0][1:0] cval, isp;
  logic [1:0][B-1:0] ren, wen; logic [1:0][B-1:0][K-1:0] addr;

  salsa_segment_pull_top #(.W(W), .K(K), .B(B), .DW(32)) u_fe (
    .clk, .rst_n(!rst),
    .q_valid(in_valid), .q_is_update(in_word.op == OP_UPDATE),
    .q_idx(in_word.key), .q_data(in_word.value),
    .iss_valid, .iss_update, .iss_cand(cand), .iss_cval(cval), .iss_isp(isp),
    .iss_ren(ren), .iss_wen(wen), .iss_addr(addr), .iss_data(data));

  logic [K:0] clr;
  always_ff @(posedge clk)
    if (rst)                clr <= '0;
    else if (!clr[K])       clr <= clr + 1'b1;
  assign init_done = !MIN || clr[K];

  logic [NL-1:0][31:0] pF;

  logic [1:0][B-1:0] cren, cwen; logic [1:0][B-1:0][K-1:0] caddr;
  always_ff @(posedge clk) begin cren <= ren; cwen <= wen; caddr <= addr; end

  (* max_fanout = 32 *) logic [9:2][HW-1:0] ancx;
  always_ff @(posedge clk) begin
    ancx[2] <= in_word.key[W-1:K];
    for (int s = 3; s <= 9; s++) ancx[s] <= ancx[s-1];
  end

  logic [B-1:0][31:0] pb;
  logic [1:0][B-1:0][31:0] wdat;
  always_comb begin
    for (int l = 0; l < B; l++) pb[l] = (l <= K) ? pF[HW + l] : ID;
    wdat[1] = rot(pb, ancx[9]);
    wdat[0] = rot(pb, -ancx[9]);
  end

  logic [1:0][B-1:0][31:0] fq, fqc;
  logic [1:0][B-1:0] wenW;
  for (genvar p = 0; p < 2; p++) begin : g_half
    for (genvar b = 0; b < B; b++) begin : g_bank
      (* ram_style = "ultra" *) logic [31:0] mem [1 << K];
      logic [31:0] qa, qq, wdr, wd10, wd11, fix;
      logic r1, r2; logic [K-1:0] ra1;
      logic [9:1] we; logic [9:1][K-1:0] wa;
      logic hst, h6, h7, h8;
`ifndef SYNTHESIS
      initial for (int i = 0; i < (1 << K); i++) mem[i] = ID;
`endif
      always_ff @(posedge clk) begin
        if (!init_done)    mem[clr[K-1:0]] <= ID;
        else if (we[8])    mem[wa[8]] <= wdr;
      end
      always_ff @(posedge clk) begin
        if (cren[p][b]) qa <= mem[caddr[p][b]];
        r1 <= cren[p][b];
        if (r1) qq <= qa;
      end
      always_ff @(posedge clk) begin
        ra1 <= caddr[p][b]; r2 <= r1;
        we[1] <= cwen[p][b]; wa[1] <= caddr[p][b];
        for (int i = 2; i <= 9; i++) begin we[i] <= we[i-1]; wa[i] <= wa[i-1]; end
        hst <= (we[2] && wa[2] == ra1) || (we[3] && wa[3] == ra1) || (we[4] && wa[4] == ra1)
            || (we[5] && wa[5] == ra1) || (we[6] && wa[6] == ra1);
        h6  <= we[7] && wa[7] == ra1;
        h7  <= we[8] && wa[8] == ra1;
        h8  <= we[9] && wa[9] == ra1;
        wdr <= wdat[p][b]; wd10 <= wdr; wd11 <= wd10;
        fq[p][b] <= fix;
      end
      always_comb begin
        if (!r2 || hst) fix = ID;
        else if (h6)    fix = wdr;
        else if (h7)    fix = wd10;
        else if (h8)    fix = wd11;
        else            fix = qq;
      end
      assign wenW[p][b] = we[8];
    end
  end
  always_ff @(posedge clk) fqc <= fq;

  always_ff @(posedge clk)
    for (int b = 0; b < B; b++)
      if (rst) bank_stores[b] <= 0;
      else     bank_stores[b] <= bank_stores[b] + 32'(wenW[0][b]) + 32'(wenW[1][b]);

  logic [NL-1:0][W:0] path2;
  always_comb for (int L = 0; L < NL; L++) path2[L] = isp[L][1] ? cand[L][1] : cand[L][0];

  word_t [9:2] wd;
  logic [9:3] uv, vv;
  logic [9:3][NL-1:0][W:0] pth;
  always_ff @(posedge clk) begin
    wd[2] <= in_word;
    for (int s = 3; s <= 9; s++) wd[s] <= wd[s-1];
    uv[3] <= !rst && iss_valid && iss_update; vv[3] <= !rst && iss_valid; pth[3] <= path2;
    for (int s = 4; s <= 9; s++) begin uv[s] <= !rst && uv[s-1]; vv[s] <= !rst && vv[s-1]; pth[s] <= pth[s-1]; end
  end

  localparam int ND = 5;
  function automatic int unsigned writer(input logic [W:0] node, input int L);
    for (int d = 1; d <= ND; d++)
      if (uv[2 + d] && pth[2 + d][L] == node) return d;
    return 0;
  endfunction

  logic [ND:1] eh2, qh2; logic [ND:1][KW-1:0] ek2; logic [ND:1][LW-1:0] el2, ql2;
  logic [NL-1:0] sd2;
  logic [HW-1:0][HW-1:0] eri2; logic [HW-1:0] eru2;
  logic [HW-1:0][1:0][HW-1:0] qri2; logic [HW-1:0][1:0] qru2;
  always_comb begin
    eh2 = '0; qh2 = '0; ek2 = '0; el2 = '0; ql2 = '0; sd2 = '0; eri2 = '0; eru2 = '0; qri2 = '0; qru2 = '0;
    for (int L = 1; L < NL; L++) begin
      automatic int sd = isp[L][1] ? 0 : 1;
      automatic int unsigned d = writer(cand[L][sd], L);
      sd2[L] = sd[0];
      if (d != 0) begin eh2[d] = 1'b1; ek2[d] = KW'(W - L + 1); el2[d] = LW'(L); end
      if (L < HW) begin eri2[L] = cand[L][sd][HW-1:0]; eru2[L] = (d == 0); end
    end
    for (int L = NL - 1; L >= 0; L--)
      for (int p = 0; p < 2; p++) begin
        automatic int unsigned d = cval[L][p] ? writer(cand[L][p], L) : 0;
        if (d != 0) begin qh2[d] = 1'b1; ql2[d] = LW'(L); end
        if (cval[L][p] && L < HW) begin qri2[L][p] = cand[L][p][HW-1:0]; qru2[L][p] = (d == 0); end
      end
  end

`ifndef SYNTHESIS
  always_ff @(posedge clk)
    if (iss_valid && iss_update)
      for (int d = 1; d <= ND; d++) begin
        int n;
        n = 0;
        for (int L = 1; L < NL; L++)
          if (writer(cand[L][isp[L][1] ? 0 : 1], L) == d) n++;
        assert (n <= 1) else $error("update %0d ahead supplies %0d siblings", d, n);
      end
`endif

  logic [8:3][ND:1] eh, qh; logic [8:3][ND:1][KW-1:0] ek; logic [8:3][ND:1][LW-1:0] el, ql;
  logic [6:3][NL-1:0] sdv; logic [6:3][31:0] v;
  logic [HW-1:0][HW-1:0] eri3; logic [HW-1:0] eru3;
  logic [HW-1:0][1:0][HW-1:0] qri3; logic [HW-1:0][1:0] qru3;
  logic [6:4][HW-1:0][R:1] eoh; logic [6:4][HW-1:0][1:0][R:1] qoh;
  logic [5:3][NL-1:0] sub6;
  logic [NL-1:0] mt2, mt1;
  always_ff @(posedge clk) begin
    eh[3] <= eh2; qh[3] <= qh2; ek[3] <= ek2; el[3] <= el2; ql[3] <= ql2;
    sdv[3] <= sd2; v[3] <= data; eri3 <= eri2; eru3 <= eru2; qri3 <= qri2; qru3 <= qru2;
    for (int s = 4; s <= 8; s++) begin eh[s] <= eh[s-1]; qh[s] <= qh[s-1]; ek[s] <= ek[s-1]; el[s] <= el[s-1]; ql[s] <= ql[s-1]; end
    for (int s = 4; s <= 6; s++) begin sdv[s] <= sdv[s-1]; v[s] <= v[s-1]; end
    for (int L = 0; L < HW; L++) begin
      for (int i = 1; i <= R; i++) eoh[4][L][i] <= eru3[L] && int'(eri3[L]) == i;
      for (int p = 0; p < 2; p++)
        for (int i = 1; i <= R; i++) qoh[4][L][p][i] <= qru3[L][p] && int'(qri3[L][p]) == i;
    end
    eoh[5] <= eoh[4]; eoh[6] <= eoh[5]; qoh[5] <= qoh[4]; qoh[6] <= qoh[5];
    for (int d = 3; d <= 5; d++)
      for (int k = 0; k < NL; k++) sub6[d][k] <= eh[5][d] && ek[5][d] == KW'(k);
    for (int k = 0; k < NL; k++) begin
      mt2[k] <= eh[7][2] && KW'(k) >= ek[7][2];
      mt1[k] <= eh[7][1] && KW'(k) >= ek[7][1];
    end
  end

  logic [R:1][31:0] root;
  function automatic logic [31:0] rd_root(input logic [R:1] oh);
    logic [31:0] acc;
    acc = '0;
    for (int i = 1; i <= R; i++) acc |= oh[i] ? root[i] : '0;
    return (|oh) ? acc : ID;
  endfunction

  function automatic logic ge(input logic [31:0] x, input logic [31:0] y);
    return MIN ? (x <= y) : (x >= y);
  endfunction

  function automatic logic [31:0] max4(input logic [31:0] a, input logic [31:0] b,
                                       input logic [31:0] c, input logic [31:0] d);
    logic ab, ac, ad, bc, bd, cd;
    ab = ge(a, b); ac = ge(a, c); ad = ge(a, d); bc = ge(b, c); bd = ge(b, d); cd = ge(c, d);
    if (ab && ac && ad)    return a;
    if (!ab && bc && bd)   return b;
    if (!ac && !bc && cd)  return c;
    return d;
  endfunction

  logic [31:0] f5, f5r, f4r, f3r, g5, g5r, g4r, g3r;

  localparam int NB = (NL + 3) / 4;
  logic [NL-1:0][31:0] e5n; logic [NB-2:0][31:0] tot5n; logic [10:0][31:0] qa5n;
  always_comb begin
    logic [B-1:0][31:0] x0, x1;
    logic [HW-1:0] a;
    logic [43:0][31:0] t;
    logic [4*NB-1:0][31:0] ep;
    a  = ancx[6];
    x1 = rot(fqc[1], -a);
    x0 = rot(fqc[0], a);
    e5n[0] = v[6];
    for (int k = 1; k < NL; k++) begin
      automatic int L = W - k + 1;
      if (L >= HW) begin
        automatic int l = L - HW;
        automatic int pos;
        if (l == 0) pos = (sdv[6][L] ^ a[0]) ? 15 : 1;
        else        pos = l;
        e5n[k] = sdv[6][L] ? x1[pos] : x0[pos];
      end else
        e5n[k] = rd_root(eoh[6][L]);
      if (sub6[3][k]) e5n[k] = f3r;
      if (sub6[4][k]) e5n[k] = f4r;
      if (sub6[5][k]) e5n[k] = f5r;
    end
    ep = '{default: ID};
    for (int k = 0; k < NL; k++) ep[k] = e5n[k];
    for (int j = 0; j < NB - 1; j++) tot5n[j] = max4(ep[4*j], ep[4*j + 1], ep[4*j + 2], ep[4*j + 3]);
    for (int i = 0; i < 2 * B; i++) t[i] = fqc[i / B][i % B];
    for (int L = 0; L < HW; L++)
      for (int p = 0; p < 2; p++) t[2 * B + 2 * L + p] = rd_root(qoh[6][L][p]);
    t[40] = g5r; t[41] = g4r; t[42] = g3r; t[43] = ID;
    for (int s = 0; s < 11; s++) qa5n[s] = max4(t[4 * s], t[4 * s + 1], t[4 * s + 2], t[4 * s + 3]);
  end

  logic [NL-1:0][31:0] e6; logic [NB-2:0][31:0] tot6; logic [10:0][31:0] qa6;
  always_ff @(posedge clk) begin e6 <= e5n; tot6 <= tot5n; qa6 <= qa5n; end

  logic [NL-1:0][31:0] ip7; logic [NB-1:0][31:0] bp7; logic [31:0] f2r, f1, g1; logic [2:0][31:0] qb7;
  function automatic logic [31:0] pval(input int k, input logic [31:0] f1v);
    return max4(ip7[k], bp7[k / 4], mt2[k] ? f2r : ID, mt1[k] ? f1v : ID);
  endfunction

  always_ff @(posedge clk) begin
    f5  <= eh[4][5] ? pF[el[4][5]] : ID;
    g5  <= qh[4][5] ? pF[ql[4][5]] : ID;
    f5r <= f5; g5r <= g5;
    f4r <= eh[5][4] ? pF[el[5][4]] : ID;
    g4r <= qh[5][4] ? pF[ql[5][4]] : ID;
    f3r <= eh[5][3] ? pval(W - int'(el[5][3]), f1) : ID;
    g3r <= qh[5][3] ? pval(W - int'(ql[5][3]), f1) : ID;
  end

  logic [NL-1:0][31:0] ip6n; logic [NB-1:0][31:0] bp6n; logic [31:0] f2n, f1n, g1n; logic [2:0][31:0] qb6n;
  always_comb begin
    logic [4*NB-1:0][31:0] ep;
    logic [31:0] g2;
    ep = '{default: ID};
    for (int k = 0; k < NL; k++) ep[k] = e6[k];
    for (int j = 0; j < NB; j++) begin
      ip6n[4*j] = ep[4*j];
      if (4*j + 1 < NL) ip6n[4*j + 1] = max4(ep[4*j], ep[4*j + 1], ID, ID);
      if (4*j + 2 < NL) ip6n[4*j + 2] = max4(ep[4*j], ep[4*j + 1], ep[4*j + 2], ID);
      if (4*j + 3 < NL) ip6n[4*j + 3] = max4(ep[4*j], ep[4*j + 1], ep[4*j + 2], ep[4*j + 3]);
      bp6n[j] = max4(j > 0 ? tot6[0] : ID, j > 1 ? tot6[1] : ID, j > 2 ? tot6[2] : ID, j > 3 ? tot6[3] : ID);
    end
    f2n = eh[7][2] ? pF[el[7][2]] : ID;
    g2  = qh[7][2] ? pF[ql[7][2]] : ID;
    f1n = eh[7][1] ? pval(W - int'(el[7][1]), f1) : ID;
    g1n = qh[7][1] ? pval(W - int'(ql[7][1]), f1) : ID;
    qb6n[0] = max4(qa6[0], qa6[1], qa6[2], qa6[3]);
    qb6n[1] = max4(qa6[4], qa6[5], qa6[6], qa6[7]);
    qb6n[2] = max4(qa6[8], qa6[9], qa6[10], g2);
  end

  always_ff @(posedge clk) begin
    ip7 <= ip6n; bp7 <= bp6n; f2r <= f2n; f1 <= f1n; g1 <= g1n; qb7 <= qb6n;
  end

  logic [NL-1:0][31:0] p7n; logic [31:0] q7n;
  always_comb begin
    for (int k = 0; k < NL; k++) p7n[W - k] = pval(k, f1);
    q7n = max4(qb7[0], qb7[1], qb7[2], g1);
  end

  logic [31:0] qo;
  logic [HW-1:0][R:1] rwo;
  always_ff @(posedge clk) begin
    pF <= p7n; qo <= q7n;
    for (int L = 0; L < HW; L++)
      for (int i = 1; i <= R; i++) rwo[L][i] <= uv[8] && int'(pth[8][L][HW-1:0]) == i;
    if (rst) begin root <= {R{ID}}; root_stores <= 0; end
    else begin
      for (int L = 0; L < HW; L++)
        for (int i = 1; i <= R; i++)
          if (rwo[L][i]) root[i] <= pF[L];
      if (uv[9]) root_stores <= root_stores + 1;
    end
  end

  always_comb begin
    out_valid = vv[9];
    out_word  = wd[9];
    if (wd[9].op != OP_UPDATE) out_word.value = qo;
  end
endmodule

module salsa import salsa_pkg::*; #(
  parameter int DEPTH = 16
) (
  input  wire        aclk, aresetn,
  input  wire [63:0] s_axis_tdata,  input  wire s_axis_tvalid, output wire s_axis_tready,
  input  wire        s_axis_tlast,
  output reg  [63:0] m_axis_tdata,  output reg  m_axis_tvalid, input  wire m_axis_tready,
  output reg         m_axis_tlast,
  input  wire [7:0]  s_axi_awaddr,  input  wire [2:0] s_axi_awprot,
  input  wire        s_axi_awvalid, output wire s_axi_awready,
  input  wire [31:0] s_axi_wdata,   input  wire [3:0] s_axi_wstrb,
  input  wire        s_axi_wvalid,  output wire s_axi_wready,
  output wire [1:0]  s_axi_bresp,   output reg  s_axi_bvalid,  input wire s_axi_bready,
  input  wire [7:0]  s_axi_araddr,  input  wire [2:0] s_axi_arprot,
  input  wire        s_axi_arvalid, output wire s_axi_arready,
  output reg  [31:0] s_axi_rdata,   output wire [1:0] s_axi_rresp,
  output reg         s_axi_rvalid,  input  wire s_axi_rready
);
`ifndef SYNTHESIS
  initial begin
    if (B > 16)    $fatal(1, "BANK_STORES has 16 slots (0x40..0x7C); widen the AXI-Lite map for B > 16");
    if (DEPTH < 10) $fatal(1, "DEPTH must cover the 9-cycle latency (input slice plus datapath) plus one");
  end
`endif

  (* max_fanout = 64 *) logic rst;
  logic rst0;
  always_ff @(posedge aclk) begin rst0 <= !aresetn; rst <= rst0; end

  logic accept, out_valid, init_done, ready, in_v;
  logic free, load, bypass, push, last;
  word_t out_word, in_w;
  logic [7:0] in_flight, count, in_flight_n, count_n;
  assign accept        = s_axis_tvalid && ready;
  assign s_axis_tready = ready;
  assign in_flight_n   = in_flight + 8'(accept) - 8'(out_valid);
  assign count_n       = count + 8'(push) - 8'(load);

  always_ff @(posedge aclk) begin
    if (rst) begin in_flight <= 0; ready <= 0; in_v <= 0; end
    else begin
      in_flight <= in_flight_n;
      ready     <= init_done && (9'(count_n) + 9'(in_flight_n) < 9'(DEPTH));
      in_v      <= accept;
    end
    in_w <= word_t'(s_axis_tdata);
  end

  logic [B-1:0][31:0] bank_stores; logic [31:0] root_stores;
  salsa_datapath u_dp (.clk(aclk), .rst,
    .in_valid(in_v), .in_word(in_w),
    .out_valid, .out_word, .bank_stores, .root_stores, .init_done);

  logic start; logic [31:0] run_len, pushed;
  logic [64:0] fifo [DEPTH];
  logic [$clog2(DEPTH)-1:0] wp, rp;
  assign free   = !m_axis_tvalid || m_axis_tready;
  assign load   = free && count != 0;
  assign bypass = free && count == 0 && out_valid;
  assign push   = out_valid && !bypass;
  assign last   = pushed == run_len - 1;
  always_ff @(posedge aclk) begin
    if (push) fifo[wp] <= {last, out_word};
    if (rst) begin
      wp <= 0; rp <= 0; count <= 0; m_axis_tvalid <= 0;
    end else begin
      if (push) wp <= wp + 1'b1;
      if (load) rp <= rp + 1'b1;
      count <= count_n;
      if (free) m_axis_tvalid <= load || bypass;
    end
    if (load)        {m_axis_tlast, m_axis_tdata} <= fifo[rp];
    else if (bypass) {m_axis_tlast, m_axis_tdata} <= {last, out_word};
    if (rst || start) pushed <= 0; else if (out_valid) pushed <= pushed + 1;
  end

  logic send, timing, done, got_first;
  logic [31:0] cycles, req_count, res_count, latency;
  assign send = m_axis_tvalid && m_axis_tready;

  always_ff @(posedge aclk)
    if (rst || start) begin
      timing <= 0; done <= 0; got_first <= 0;
      cycles <= 0; req_count <= 0; res_count <= 0; latency <= 0;
    end else begin
      if (accept && !timing && !done) timing <= 1;
      if (timing || (accept && !done)) cycles <= cycles + 1;
      if (timing && !got_first) latency <= latency + 1;
      if (send) got_first <= 1;
      if (send && m_axis_tlast) begin timing <= 0; done <= 1; end
      req_count <= req_count + 32'(accept);
      res_count <= res_count + 32'(send);
    end

  logic wr;
  assign s_axi_awready = wr;
  assign s_axi_wready  = wr;
  assign s_axi_arready = !rst && !s_axi_rvalid;
  assign s_axi_bresp = 0;
  assign s_axi_rresp = 0;

  always_ff @(posedge aclk) begin
    wr    <= !rst && !wr && s_axi_awvalid && s_axi_wvalid && (!s_axi_bvalid || s_axi_bready);
    start <= wr && s_axi_awaddr[7:2] == 0 && s_axi_wdata[0];
    if (rst) run_len <= 0; else if (wr && s_axi_awaddr[7:2] == 2) run_len <= s_axi_wdata;

    if (rst) s_axi_bvalid <= 0; else if (wr) s_axi_bvalid <= 1; else if (s_axi_bready) s_axi_bvalid <= 0;
    if (rst) s_axi_rvalid <= 0; else if (s_axi_arvalid && s_axi_arready) s_axi_rvalid <= 1;
    else if (s_axi_rready) s_axi_rvalid <= 0;

    if (!s_axi_rvalid || s_axi_rready)
      case (s_axi_araddr[7:2])
        1:  s_axi_rdata <= {30'd0, init_done, done};
        2:  s_axi_rdata <= run_len;
        3:  s_axi_rdata <= cycles;
        4:  s_axi_rdata <= req_count;
        5:  s_axi_rdata <= res_count;
        6:  s_axi_rdata <= latency;
        32: s_axi_rdata <= root_stores;
        default: s_axi_rdata <= (s_axi_araddr[7:6] == 1 && 32'(s_axi_araddr[5:2]) < B)
                                ? bank_stores[s_axi_araddr[5:2]] : 0;
      endcase
  end

  wire unused = ^{s_axis_tlast, s_axi_awprot, s_axi_arprot, s_axi_wstrb, s_axi_awaddr[1:0], s_axi_araddr[1:0]};
endmodule
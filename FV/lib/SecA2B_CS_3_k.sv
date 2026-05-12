// ============================================================================
// SecA2B_CS_3_k: Convert 3 arithmetic shares to (s,c) Boolean shares
//   such that s_plain + c_plain = sum(arithmetic shares) mod 2^k
//   Latency: 2 cycles (SecCSA latency)
// ============================================================================
module SecA2B_CS_3_k #(
    parameter integer k = 8
) (
    input  wire clk,
    input  wire [3*k-1:0] ina,          // three arithmetic shares
    input  wire [3*k-1:0] rnd,          // randomness for SecCSA_3_k (width = k*3*2/2 = 3k)
    output wire [3*k-1:0] outs,         // s shares (Boolean)
    output wire [3*k-1:0] outc          // c shares (Boolean)
);

    // Extract arithmetic shares (share‑major order)
    wire [k-1:0] a0 = ina[0*k +: k];
    wire [k-1:0] a1 = ina[1*k +: k];
    wire [k-1:0] a2 = ina[2*k +: k];

    // Build Boolean inputs for SecCSA: each input is a 3‑share Boolean vector
    // (y1): share0 = a0, share1 = 0, share2 = 0
    // (y2): share0 = 0, share1 = a1, share2 = 0
    // (y3): share0 = 0, share1 = 0, share2 = a2
    wire [3*k-1:0] y1, y2, y3;

    assign y1 = { {2*k{1'b0}}, a0 };          // share2, share1, share0
    assign y2 = { {k{1'b0}}, a1, {k{1'b0}} };
    assign y3 = { a2, {2*k{1'b0}} };

    // Instantiate SecCSA_3_k
    SecCSA_n_k #(.n(3), .k(k)) csa_inst (
        .clk(clk),
        .ina(y1),
        .inb(y2),
        .incin(y3),
        .rnd(rnd),
        .outs(outs),
        .outc(outc)
    );

endmodule
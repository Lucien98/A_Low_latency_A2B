// ============================================================================
// SecA2B_CS_4_k: Convert 4 arithmetic shares to (s,c) Boolean shares
//   Uses two CSA layers: first on a0,a1,a2, then combine with a3.
//   Total randomness = 3k (first CSA) + 6k (second CSA) = 9k bits
// ============================================================================
module SecA2B_CS_4_k #(
    parameter integer k = 8
) (
    input  wire clk,
    input  wire [4*k-1:0] ina,          // arithmetic shares {a3, a2, a1, a0}
    input  wire [9*k-1:0] rnd,          // exactly 9k bits
    output wire [4*k-1:0] outs,
    output wire [4*k-1:0] outc
);

    localparam RND_CSA3 = 3*k;           // for SecA2B_CS_3_k
    localparam RND_CSA4 = 6*k;           // for SecCSA_n_k with n=4

    // Extract shares
    wire [k-1:0] a0 = ina[0*k +: k];
    wire [k-1:0] a1 = ina[1*k +: k];
    wire [k-1:0] a2 = ina[2*k +: k];
    wire [k-1:0] a3 = ina[3*k +: k];

    // ---- First CSA layer: convert a0,a1,a2 -> (s1,c1) ----
    wire [3*k-1:0] s1, c1;
    wire [RND_CSA3-1:0] rnd3 = rnd[RND_CSA3-1:0];
    SecA2B_CS_3_k #(.k(k)) cs3 (
        .clk(clk),
        .ina({a2, a1, a0}),
        .rnd(rnd3),
        .outs(s1),
        .outc(c1)
    );

    // ---- Build 4‑share Boolean vectors for the second CSA ----
    // (y1): shares of s1 padded with a zero share (share3=0)
    // (y2): shares of c1 padded with a zero share
    // (y3): only share3 = a3, others zero
    wire [4*k-1:0] y1 = { {k{1'b0}}, s1 };   // s1 has 3 shares, add zero as share3
    wire [4*k-1:0] y2 = { {k{1'b0}}, c1 };
    wire [4*k-1:0] y3 = { a3, {3*k{1'b0}} };

    // ---- Second CSA layer (n=4) ----
    wire [RND_CSA4-1:0] rnd4 = rnd[RND_CSA3 +: RND_CSA4];
    SecCSA_n_k #(.n(4), .k(k)) csa4 (
        .clk(clk),
        .ina(y1),
        .inb(y2),
        .incin(y3),
        .rnd(rnd4),
        .outs(outs),
        .outc(outc)
    );

endmodule
// File: ./lib/SecA2B_4_k.sv
module SecA2B_4_k #(
    parameter integer k = 8
) (
    input  wire clk,
    input  wire [4*k-1:0]          ina,
    input  wire [ (2*$clog2(k-1) * k * (1+1+6) ) - 1 : 0 ] rnd,  // two SecA2B_2 + one SecKSA_4
    output wire [4*k-1:0]          out
);
    localparam L = $clog2(k-1);                    // =3
    localparam RND_KSA_2 = 2 * L * k * 1;          // 48 bits
    localparam RND_KSA_4 = 2 * L * k * 6;          // 288 bits (n=4 -> n(n-1)/2=6)
    localparam RND_TOTAL = 2 * RND_KSA_2 + RND_KSA_4; // 48+48+288=384 bits

    wire [k-1:0] a0 = ina[0*k +: k];
    wire [k-1:0] a1 = ina[1*k +: k];
    wire [k-1:0] a2 = ina[2*k +: k];
    wire [k-1:0] a3 = ina[3*k +: k];

    wire [2*k-1:0] b0_b1;
    wire [RND_KSA_2-1:0] rnd_2_0 = rnd[RND_KSA_2-1:0];
    SecA2B_2_k #(.k(k)) conv01 (
        .clk(clk),
        .ina({a1, a0}),
        .rnd(rnd_2_0),
        .out(b0_b1)
    );
    wire [k-1:0] b0 = b0_b1[0*k +: k];
    wire [k-1:0] b1 = b0_b1[1*k +: k];

    wire [2*k-1:0] b2_b3;
    wire [RND_KSA_2-1:0] rnd_2_1 = rnd[RND_KSA_2 +: RND_KSA_2];
    SecA2B_2_k #(.k(k)) conv23 (
        .clk(clk),
        .ina({a3, a2}),
        .rnd(rnd_2_1),
        .out(b2_b3)
    );
    wire [k-1:0] b2 = b2_b3[0*k +: k];
    wire [k-1:0] b3 = b2_b3[1*k +: k];

    wire [4*k-1:0] s, sprime;
    assign s[0*k +: k] = b0;
    assign s[1*k +: k] = b1;
    assign s[2*k +: k] = {k{1'b0}};
    assign s[3*k +: k] = {k{1'b0}};
    assign sprime[0*k +: k] = {k{1'b0}};
    assign sprime[1*k +: k] = {k{1'b0}};
    assign sprime[2*k +: k] = b2;
    assign sprime[3*k +: k] = b3;

    wire [RND_KSA_4-1:0] rnd_add = rnd[2*RND_KSA_2 +: RND_KSA_4];
    SecKSA_n_k #(.n(4), .k(k)) adder (
        .clk(clk),
        .ina(s),
        .inb(sprime),
        .rnd(rnd_add),
        .out(out)
    );
endmodule
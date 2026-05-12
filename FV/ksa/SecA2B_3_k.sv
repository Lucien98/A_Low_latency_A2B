// File: ./lib/SecA2B_3_k.sv
module SecA2B_3_k #(
    parameter integer k = 8
) (
    input  wire clk,
    input  wire [3*k-1:0]          ina,
    input  wire [ (2*$clog2(k-1) * k * (1 + 3) ) - 1 : 0 ] rnd,  // see calculation
    output wire [3*k-1:0]          out
);
    localparam L = $clog2(k-1);                    // =3 for k=8
    localparam RND_KSA_2 = 2 * L * k * 1;          // 48 bits for n=2 sub-module
    localparam RND_KSA_3 = 2 * L * k * 3;          // 144 bits for n=3 adder
    localparam RND_TOTAL = RND_KSA_2 + RND_KSA_3;  // 48+144=192 bits
    // The port width must match RND_TOTAL; the formula in the port declaration automatically checks.

    wire [k-1:0] a0 = ina[0*k +: k];
    wire [k-1:0] a1 = ina[1*k +: k];
    wire [k-1:0] a2 = ina[2*k +: k];

    wire [k-1:0] b0;
    SecA2B_1_k #(.k(k)) conv0 (.ina(a0), .out(b0));

    wire [2*k-1:0] b1_b2;
    wire [RND_KSA_2-1:0] rnd_2 = rnd[RND_KSA_2-1:0];
    SecA2B_2_k #(.k(k)) conv12 (
        .clk(clk),
        .ina({a2, a1}),
        .rnd(rnd_2),
        .out(b1_b2)
    );
    wire [k-1:0] b1 = b1_b2[0*k +: k];
    wire [k-1:0] b2 = b1_b2[1*k +: k];

    wire [3*k-1:0] s, sprime;
    assign s[0*k +: k] = b0;
    assign s[1*k +: k] = {k{1'b0}};
    assign s[2*k +: k] = {k{1'b0}};
    assign sprime[0*k +: k] = {k{1'b0}};
    assign sprime[1*k +: k] = b1;
    assign sprime[2*k +: k] = b2;

    wire [RND_KSA_3-1:0] rnd_add = rnd[RND_KSA_2 +: RND_KSA_3];
    SecKSA_n_k #(.n(3), .k(k)) adder (
        .clk(clk),
        .ina(s),
        .inb(sprime),
        .rnd(rnd_add),
        .out(out)
    );
endmodule
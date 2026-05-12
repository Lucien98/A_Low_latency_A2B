// File: ./lib/SecA2B_4_k.sv
module SecA2B_4_k #(
    parameter integer k = 8
) (
    input  wire clk,
    input  wire [4*k-1:0]          ina,   // four arithmetic shares
    input  wire [8*(k-1)-1:0]      rnd,   // rnd = [rnd_2_0 | rnd_2_1 | rnd_add]
    output wire [4*k-1:0]          out    // four Boolean shares
);

    localparam RND_2_WIDTH   = (k-1);
    localparam RND_ADD_WIDTH = 6*(k-1);       // for d=4

    // ---------- Split arithmetic shares into two halves of size 2 ----------
    wire [k-1:0] a0 = ina[0*k +: k];
    wire [k-1:0] a1 = ina[1*k +: k];
    wire [k-1:0] a2 = ina[2*k +: k];
    wire [k-1:0] a3 = ina[3*k +: k];

    // ---------- Convert first half (shares 0,1) ----------
    wire [2*k-1:0] b0_b1;
    wire [RND_2_WIDTH-1:0] rnd_2_0 = rnd[RND_2_WIDTH-1:0];
    SecA2B_2_k #(.k(k)) conv01 (
        .clk(clk),
        .ina({a1, a0}),    // order: share0 = a0, share1 = a1
        .rnd(rnd_2_0),
        .out(b0_b1)
    );
    wire [k-1:0] b0 = b0_b1[0*k +: k];
    wire [k-1:0] b1 = b0_b1[1*k +: k];

    // ---------- Convert second half (shares 2,3) ----------
    wire [2*k-1:0] b2_b3;
    wire [RND_2_WIDTH-1:0] rnd_2_1 = rnd[RND_2_WIDTH +: RND_2_WIDTH];
    SecA2B_2_k #(.k(k)) conv23 (
        .clk(clk),
        .ina({a3, a2}),    // order: share0 = a2, share1 = a3
        .rnd(rnd_2_1),
        .out(b2_b3)
    );
    wire [k-1:0] b2 = b2_b3[0*k +: k];
    wire [k-1:0] b3 = b2_b3[1*k +: k];

    // ---------- Pad to 4 shares ----------
    // s   = (b0, b1, 0, 0)
    // s'  = (0, 0, b2, b3)
    wire [4*k-1:0] s, sprime;
    assign s      [0*k +: k] = b0;
    assign s      [1*k +: k] = b1;
    assign s      [2*k +: k] = {k{1'b0}};
    assign s      [3*k +: k] = {k{1'b0}};
    assign sprime [0*k +: k] = {k{1'b0}};
    assign sprime [1*k +: k] = {k{1'b0}};
    assign sprime [2*k +: k] = b2;
    assign sprime [3*k +: k] = b3;

    // ---------- Masked addition (d=4) ----------
    wire [RND_ADD_WIDTH-1:0] rnd_add = rnd[2*RND_2_WIDTH +: RND_ADD_WIDTH];
    SecRCA_n_k #(.n(4), .k(k)) adder (
        .clk(clk),
        .ina(s),
        .inb(sprime),
        .rnd(rnd_add),
        .out(out)
    );

endmodule
// File: ./lib/SecA2B_3_k.sv
module SecA2B_3_k #(
    parameter integer k = 8
) (
    input  wire clk,
    input  wire [3*k-1:0]          ina,   // three arithmetic shares
    input  wire [4*(k-1)-1:0]      rnd,   // rnd = [rnd_2 | rnd_add]
    output wire [3*k-1:0]          out    // three Boolean shares
);

    localparam RND_2_WIDTH   = (k-1);            // for SecA2B_2_k
    localparam RND_ADD_WIDTH = 3*(k-1);          // for SecRCA with d=3

    // ---------- Split arithmetic shares ----------
    wire [k-1:0] a0 = ina[0*k +: k];
    wire [k-1:0] a1 = ina[1*k +: k];
    wire [k-1:0] a2 = ina[2*k +: k];

    // ---------- Convert first half (size 1) ----------
    wire [k-1:0] b0;
    SecA2B_1_k #(.k(k)) conv0 (.ina(a0), .out(b0));

    // ---------- Convert second half (size 2) ----------
    wire [2*k-1:0] b1_b2;   // Boolean shares of a1,a2 (2 shares)
    wire [RND_2_WIDTH-1:0] rnd_2 = rnd[RND_2_WIDTH-1:0];
    SecA2B_2_k #(.k(k)) conv12 (
        .clk(clk),
        .ina({a2, a1}),        // order: share0 = a1, share1 = a2? Wait consistent: input to SecA2B_2 expects share0,share1 in order. We have a1 (second arithmetic share) and a2 (third). We'll pack as [a2, a1]? Actually our SecA2B_2 expects ina[0:k-1]=first arithmetic share, ina[k:2k-1]=second. So we give {a2, a1} to match index order: share0 = a1, share1 = a2. But arithmetic shares are just numbers, order doesn't matter for sum. We'll be consistent: the order of arithmetic shares is arbitrary as long as the sum is correct. So we pass {a2, a1}.
        .rnd(rnd_2),
        .out(b1_b2)
    );
    wire [k-1:0] b1 = b1_b2[0*k +: k];
    wire [k-1:0] b2 = b1_b2[1*k +: k];

    // ---------- Pad to 3 shares ----------
    // s   = (b0, 0, 0)
    // s'  = (0, b1, b2)
    wire [3*k-1:0] s, sprime;
    assign s      [0*k +: k] = b0;
    assign s      [1*k +: k] = {k{1'b0}};
    assign s      [2*k +: k] = {k{1'b0}};
    assign sprime [0*k +: k] = {k{1'b0}};
    assign sprime [1*k +: k] = b1;
    assign sprime [2*k +: k] = b2;

    // ---------- Masked addition (d=3) ----------
    wire [RND_ADD_WIDTH-1:0] rnd_add = rnd[RND_2_WIDTH +: RND_ADD_WIDTH];
    SecRCA_n_k #(.n(3), .k(k)) adder (
        .clk(clk),
        .ina(s),
        .inb(sprime),
        .rnd(rnd_add),
        .out(out)
    );

endmodule
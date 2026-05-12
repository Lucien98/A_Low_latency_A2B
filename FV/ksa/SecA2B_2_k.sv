// File: ./lib/SecA2B_2_k.sv
module SecA2B_2_k #(
    parameter integer k = 8
) (
    input  wire clk,
    input  wire [2*k-1:0]          ina,   // two arithmetic shares
    input  wire [ (2 * $clog2(k-1) * k * 1) - 1 : 0] rnd,  // SecKSA randomness width for n=2
    output wire [2*k-1:0]          out
);
    localparam L = $clog2(k-1);            // =3 for k=8
    localparam RND_KSA_WIDTH = 2 * L * k * 1; // 48 bits for k=8

    wire [k-1:0] a0 = ina[0*k +: k];
    wire [k-1:0] a1 = ina[1*k +: k];

    wire [k-1:0] b0, b1;
    SecA2B_1_k #(.k(k)) conv0 (.ina(a0), .out(b0));
    SecA2B_1_k #(.k(k)) conv1 (.ina(a1), .out(b1));

    wire [2*k-1:0] s, sprime;
    assign s[0*k +: k] = b0;
    assign s[1*k +: k] = {k{1'b0}};
    assign sprime[0*k +: k] = {k{1'b0}};
    assign sprime[1*k +: k] = b1;

    SecKSA_n_k #(.n(2), .k(k)) adder (
        .clk(clk),
        .ina(s),
        .inb(sprime),
        .rnd(rnd),        // full randomness passed directly
        .out(out)
    );
endmodule
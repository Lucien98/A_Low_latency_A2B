// File: ./lib/SecA2B_2_k.sv
module SecA2B_2_k #(
    parameter integer k = 8
) (
    input  wire [2*k-1:0]          ina,   // two arithmetic shares
    input  wire [  (k-1) -1:0]     rnd,   // randomness for SecAdd_2
    input clk,
    output wire [2*k-1:0]          out    // two Boolean shares
);

    // ---------- Split arithmetic shares ----------
    wire [k-1:0] a0 = ina[0*k +: k];   // share 0
    wire [k-1:0] a1 = ina[1*k +: k];   // share 1

    // ---------- Convert each share to Boolean (n=1) ----------
    wire [k-1:0] b0, b1;
    SecA2B_1_k #(.k(k)) conv0 (.ina(a0), .out(b0));
    SecA2B_1_k #(.k(k)) conv1 (.ina(a1), .out(b1));

    // ---------- Pad to 2 shares for addition ----------
    // s   = (b0, 0)
    // s'  = (0, b1)
    wire [2*k-1:0] s, sprime;
    assign s      [0*k +: k] = b0;
    assign s      [1*k +: k] = {k{1'b0}};
    assign sprime [0*k +: k] = {k{1'b0}};
    assign sprime [1*k +: k] = b1;

    // ---------- Masked addition (SecAdd = SecRCA) ----------
    SecRCA_n_k #(.k(k)) adder (
        .clk(clk),
        .ina(s),
        .inb(sprime),
        .rnd(rnd),
        .out(out)
    );

endmodule
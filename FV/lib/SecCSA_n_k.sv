// ============================================================================
// SecCSA_n_k: n‑share Boolean masked carry‑save adder
//   s + c = x + y + cin (mod 2^k)
//   Latency: 2 cycles (aligned with SecAnd_n_k)
// ============================================================================
module SecCSA_n_k #(
    parameter integer n = 2,
    parameter integer k = 8
)(
    input  wire clk,
    input  wire [n*k-1:0] ina,
    input  wire [n*k-1:0] inb,
    input  wire [n*k-1:0] incin,
    input  wire [k*n*(n-1)/2-1:0] rnd,

    output wire [n*k-1:0] outs,
    output wire [n*k-1:0] outc
);

    function [n*k-1:0] shift_left_one;
        input [n*k-1:0] vec;
        integer s,b;
        begin
            shift_left_one = 0;

            for (s=0;s<n;s=s+1)
                for (b=1;b<k;b=b+1)
                    shift_left_one[s*k+b] = vec[s*k+b-1];
        end
    endfunction

    wire [n*k-1:0] a;
    wire [n*k-1:0] s_comb;
    wire [n*k-1:0] t;

    assign a      = ina ^ inb;
    assign s_comb = incin ^ a;
    assign t      = ina ^ incin;

    wire [n*k-1:0] and_out;

    SecAnd_n_k #(
        .d(n),
        .k(k)
    ) secand_inst (
        .clk(clk),
        .ina(a),
        .inb(t),
        .rnd(rnd),
        .out(and_out)
    );

    wire [n*k-1:0] c_comb;

    assign c_comb = shift_left_one(ina ^ and_out);

    // align latency with SecAnd (2 cycles)

    reg [n*k-1:0] s_d1, s_d2;

    always @(posedge clk) begin
        s_d1 <= s_comb;
        s_d2 <= s_d1;
    end

    assign outs = s_d2;
    assign outc = c_comb;

endmodule
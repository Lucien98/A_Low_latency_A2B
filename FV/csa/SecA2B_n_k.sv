// ============================================================================
// SecA2B_n_k: Arithmetic to Boolean masking using CSA + KSA
//   n = 2,3,4 ; k = bit width (default 8)
//   rnd port width is set large (1024) to avoid complex compile-time calculation.
//   Internally only needed bits are used.
// ============================================================================
module SecA2B_n_k #(
    parameter integer n = 2,
    parameter integer k = 8
) (
    input  wire clk,
    input  wire [n*k-1:0] ina,
    input  wire [1023:0] rnd,                // ample randomness (>= required)
    output wire [n*k-1:0] out
);

    localparam L = $clog2(k-1);              // KSA stages
    localparam RND_KSA_2 = 2*L * k * 1;
    localparam RND_KSA_3 = 2*L * k * 3;
    localparam RND_KSA_4 = 2*L * k * 6;
    localparam RND_CSA_3 = 3*k;
    localparam RND_CSA_4 = 9*k;

    generate
        if (n == 2) begin : gen_n2
            wire [k-1:0] a0 = ina[0*k +: k];
            wire [k-1:0] a1 = ina[1*k +: k];
            wire [2*k-1:0] s = { {k{1'b0}}, a0 };
            wire [2*k-1:0] c = { a1, {k{1'b0}} };
            SecKSA_n_k #(.n(2), .k(k)) ksa_inst (
                .clk(clk), .ina(s), .inb(c),
                .rnd(rnd[RND_KSA_2-1:0]),
                .out(out)
            );
        end else if (n == 3) begin : gen_n3
            wire [3*k-1:0] s_rec, c_rec;
            SecA2B_CS_3_k #(.k(k)) csa_inst (
                .clk(clk), .ina(ina[3*k-1:0]),
                .rnd(rnd[RND_CSA_3-1:0]),
                .outs(s_rec), .outc(c_rec)
            );
            SecKSA_n_k #(.n(3), .k(k)) ksa_inst (
                .clk(clk), .ina(s_rec), .inb(c_rec),
                .rnd(rnd[RND_CSA_3 +: RND_KSA_3]),
                .out(out)
            );
        end else if (n == 4) begin : gen_n4
            wire [4*k-1:0] s_rec, c_rec;
            SecA2B_CS_4_k #(.k(k)) csa_inst (
                .clk(clk), .ina(ina[4*k-1:0]),
                .rnd(rnd[RND_CSA_4-1:0]),
                .outs(s_rec), .outc(c_rec)
            );
            SecKSA_n_k #(.n(4), .k(k)) ksa_inst (
                .clk(clk), .ina(s_rec), .inb(c_rec),
                .rnd(rnd[RND_CSA_4 +: RND_KSA_4]),
                .out(out)
            );
        end else begin
            initial $error("SecA2B_n_k: n must be 2,3,4");
        end
    endgenerate

endmodule
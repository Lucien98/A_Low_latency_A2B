`ifndef DEFAULTSHARES
`define DEFAULTSHARES 2
`endif
module bin_REG
#
(
    parameter integer W = 1
)
(
    input clk,
    input [W-1:0] in,
    output [W-1:0] out
);

reg [W-1:0] regi;
always@(posedge clk)
    regi <= in;

assign out = regi;

endmodule
module MSKand_hpc2 #(parameter integer d=`DEFAULTSHARES) (ina, inb, rnd, clk, out);

localparam hpc2rnd = d*(d-1)/2;

(* fv_type = "sharing", fv_latency = 1 *)
input  [d-1:0] ina;
(* fv_type = "sharing", fv_latency = 0 *)
input  [d-1:0] inb;
(* fv_type = "random", fv_count = 1, fv_rnd_lat_0 = 0, fv_rnd_count_0 = hpc2rnd *)
input [hpc2rnd-1:0] rnd;
(* fv_type = "clock" *)
input clk;
(* fv_type = "random", fv_type = "sharing", fv_latency = 2 *)
output [d-1:0] out;

MSKand_hpc2_cross #(.d(d), .have_inner(1))
inner(
    .ina(ina),
    .inb(inb),
    .rnd(rnd),
    .clk(clk),
    .out(out)
);

endmodule
module MSKand_hpc2_cross #(parameter integer d=`DEFAULTSHARES, parameter integer have_inner=0)
(ina, inb, rnd, clk, out);

localparam hpc2rnd = d*(d-1)/2;

(* fv_type = "sharing", fv_latency = 1 *)
input  [d-1:0] ina;
(* fv_type = "sharing", fv_latency = 0 *)
input  [d-1:0] inb;
(* fv_type = "random", fv_count = 1, fv_rnd_lat_0 = 0, fv_rnd_count_0 = hpc2rnd *)
input [hpc2rnd-1:0] rnd;
(* fv_type = "clock" *)
input clk;
(* fv_type = "random", fv_type = "sharing", fv_latency = 2 *)
output [d-1:0] out;

genvar i,j;

// unpack vector to matrix --> easier for randomness handling
//reg [hpc2rnd-1:0] rnd_prev;
wire [hpc2rnd-1:0] rnd_prev;
bin_REG #(.W(hpc2rnd)) REGin_rnd_prev (
    .clk(clk),
    .in(rnd),
    .out(rnd_prev)
);

wire [d-1:0] rnd_mat [d];
wire [d-1:0] rnd_mat_prev [d];
for(i=0; i<d; i=i+1) begin: gen_igen
    assign rnd_mat[i][i] = 0;
    assign rnd_mat_prev[i][i] = 0;
    for(j=i+1; j<d; j=j+1) begin: gen_jgen
        assign rnd_mat[j][i] = rnd[((i*d)-i*(i+1)/2)+(j-1-i)];
        // The next line is equivalent to
        //assign rnd_mat[i][j] = rnd_mat[j][i];
        // but we changed it for Verilator efficient
        // simulation -> Avoid UNOPFLAT Warning (x2 simulation perfs enabled)
        assign rnd_mat[i][j] = rnd[((i*d)-i*(i+1)/2)+(j-1-i)];
        assign rnd_mat_prev[j][i] = rnd_prev[((i*d)-i*(i+1)/2)+(j-1-i)];
        // The next line is equivalent to
        //assign rnd_mat_prev[i][j] = rnd_mat_prev[j][i];
        // but we changed it for Verilator efficient simulation -> Avoid UNOPFLAT Warning (x2 simulation perfs enabled)
        assign rnd_mat_prev[i][j] = rnd_prev[((i*d)-i*(i+1)/2)+(j-1-i)];
    end
end

for(i=0; i<d; i=i+1) begin: gen_ParProdI
    wire [d-2:0] u, v, w;
    if (have_inner == 1) begin: gen_inner
        wire inb_prev, aibi;
        bin_REG #(.W(1)) REGin_inb_prev (
            .clk(clk),
            .in(inb[i]),
            .out(inb_prev)
        );
        bin_REG #(.W(1)) REGin_aibi(
            .clk(clk),
            .in(ina[i] & inb_prev),
            .out(aibi)
        );
        assign out[i] = aibi ^ ^u ^ ^w;
    end else begin: gen_others
        assign out[i] = ^u ^ ^w;
    end
    for(j=0; j<d; j=j+1) begin: gen_ParProdJ
        if (i != j) begin: gen_NotEq
            localparam integer j2 = j < i ?  j : j-1;
            //  u[j2] = Reg(not(a_i)*r_ij)
            wire u_comb = ~ina[i] & rnd_mat_prev[i][j];
            bin_REG #(.W(1)) REGin_u(
                .clk(clk),
                .in(u_comb),
                .out(u[j2])
            );
            // w[j2] = Reg[a_i * Reg(b_j + r_ij)]
            wire v_comb = inb[j] ^ rnd_mat[i][j];
            bin_REG #(.W(1)) REGin_v(
                .clk(clk),
                .in(v_comb),
                .out(v[j2])
            );
            wire w_comb = ina[i] & v[j2];
            bin_REG #(.W(1)) REGin_w(
                .clk(clk),
                .in(w_comb),
                .out(w[j2])
            );
        end
    end
end

endmodule
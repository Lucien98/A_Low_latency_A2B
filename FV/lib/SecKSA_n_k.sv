module SecKSA_n_k #(
    parameter integer n = 2,
    parameter integer k = 8
)(
    input  wire clk,
    input  wire [n*k-1:0] ina,
    input  wire [n*k-1:0] inb,
    input  wire [(2*$clog2(k-1))*k*n*(n-1)/2-1:0] rnd,
    output wire [n*k-1:0] out
);

localparam integer L = $clog2(k-1);
localparam integer RND_PER_AND = k*n*(n-1)/2;

function [n*k-1:0] shift_left;
    input [n*k-1:0] vec;
    input integer s;
    integer sh, b;
    begin
        shift_left = 0;
        for (sh=0; sh<n; sh=sh+1)
            for (b=s; b<k; b=b+1)
                shift_left[sh*k+b] = vec[sh*k+b-s];
    end
endfunction

// --------------------------------------------------------------------
// stage arrays
// --------------------------------------------------------------------

wire [n*k-1:0] p_stage [0:L];
wire [n*k-1:0] g_stage [0:L];

// --------------------------------------------------------------------
// initial p
// --------------------------------------------------------------------

assign p_stage[0] = ina ^ inb;

// --------------------------------------------------------------------
// initial g = a & b
// --------------------------------------------------------------------

wire [n*k-1:0] g0_raw;

SecAnd_n_k #(.d(n), .k(k)) secand_init (
    .clk(clk),
    .ina(ina),
    .inb(inb),
    .rnd(rnd[0 +: RND_PER_AND]),
    .out(g0_raw)
);

// align latency
reg [n*k-1:0] p0_d1, p0_d2;

always @(posedge clk) begin
    p0_d1 <= p_stage[0];
    p0_d2 <= p0_d1;
end

assign g_stage[0] = g0_raw;

// --------------------------------------------------------------------
// KSA stages
// --------------------------------------------------------------------

genvar st;

generate
for (st=0; st<L-1; st=st+1) begin : STAGE

    localparam integer SHIFT = (1 << st);
    localparam integer RIDX0 = (1 + 2*st)*RND_PER_AND;
    localparam integer RIDX1 = (2 + 2*st)*RND_PER_AND;

    wire [n*k-1:0] g_shift;
    wire [n*k-1:0] p_shift;

    assign g_shift = shift_left(g_stage[st], SHIFT);
    assign p_shift = shift_left(p_stage[st], SHIFT);

    wire [n*k-1:0] and_pg;
    wire [n*k-1:0] and_pp;

    SecAnd_n_k #(.d(n), .k(k)) secand_pg (
        .clk(clk),
        .ina(p_stage[st]),
        .inb(g_shift),
        .rnd(rnd[RIDX0 +: RND_PER_AND]),
        .out(and_pg)
    );

    SecAnd_n_k #(.d(n), .k(k)) secand_pp (
        .clk(clk),
        .ina(p_stage[st]),
        .inb(p_shift),
        .rnd(rnd[RIDX1 +: RND_PER_AND]),
        .out(and_pp)
    );

    // ------------------------------------------------------------
    // delay bypass paths by 2 cycles
    // ------------------------------------------------------------

    reg [n*k-1:0] g_d1, g_d2;

    always @(posedge clk) begin
        g_d1 <= g_stage[st];
        g_d2 <= g_d1;
    end

    assign g_stage[st+1] = g_d2 ^ and_pg;
    assign p_stage[st+1] = and_pp;

end
endgenerate

// --------------------------------------------------------------------
// final stage
// --------------------------------------------------------------------

wire [n*k-1:0] g_shift_final;
wire [n*k-1:0] and_final;

assign g_shift_final = shift_left(g_stage[L-1], 1<<(L-1));

SecAnd_n_k #(.d(n), .k(k)) secand_final (
    .clk(clk),
    .ina(p_stage[L-1]),
    .inb(g_shift_final),
    .rnd(rnd[(2*L-1)*RND_PER_AND +: RND_PER_AND]),
    .out(and_final)
);

reg [n*k-1:0] gfd1, gfd2;

always @(posedge clk) begin
    gfd1 <= g_stage[L-1];
    gfd2 <= gfd1;
end

wire [n*k-1:0] g_final;

assign g_final = gfd2 ^ and_final;

// --------------------------------------------------------------------
// sum
// --------------------------------------------------------------------

assign out = ina ^ inb ^ shift_left(g_final,1);

endmodule
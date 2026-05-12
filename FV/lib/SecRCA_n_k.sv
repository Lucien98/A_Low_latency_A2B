// ============================================================================
// SecRCA_n_k: Unrolled n‑share Boolean masked adder modulo 2^k
//              using SecAnd_n_1 for each carry bit.
// Latency = 2*(k-1) clock cycles (each SecAnd has 2-cycle latency)
// No control signals: inputs are sampled continuously, output valid after
// the fixed latency assuming inputs remain constant.
// ============================================================================
module SecRCA_n_k #(
    parameter integer n = 2,               // number of shares
    parameter integer k = 8                // bit width
) (
    input  wire                               clk,
    input  wire [k*n-1:0]                     ina,   // shares of a (share-major)
    input  wire [k*n-1:0]                     inb,   // shares of b (share-major)
    input  wire [(k-1)*n*(n-1)/2-1:0]         rnd,   // randomness for each SecAnd
    output wire [k*n-1:0]                     out    // shares of a+b mod 2^k
);

    // ------------------------------------------------------------------------
    // Local parameters
    // ------------------------------------------------------------------------
    localparam RND_PER_BIT = n*(n-1)/2;   // randomness needed for one SecAnd_1

    // ------------------------------------------------------------------------
    // Extract per‑bit share vectors (share‑major -> bit‑major)
    // ------------------------------------------------------------------------
    wire [n-1:0] xb [0:k-1];   // shares of a's bit j
    wire [n-1:0] yb [0:k-1];   // shares of b's bit j
    genvar b, s;
    generate
        for (b = 0; b < k; b = b + 1) begin : gen_extract
            for (s = 0; s < n; s = s + 1) begin : gen_share
                assign xb[b][s] = ina[s*k + b];
                assign yb[b][s] = inb[s*k + b];
            end
        end
    endgenerate

    // ------------------------------------------------------------------------
    // Carry chain: c[0] = 0 (all shares zero), c[j] = carry after bit j-1
    // For j = 0 .. k-2:
    //   a     = xb[j] ^ yb[j]
    //   z[j]  = c[j] ^ a
    //   t     = xb[j] ^ c[j]
    //   c[j+1]= xb[j] ^ SecAnd_1(a, t)
    // Finally, z[k-1] = xb[k-1] ^ yb[k-1] ^ c[k-1]
    // ------------------------------------------------------------------------
    wire [n-1:0] c [0:k-1];   // c[0] = 0
    wire [n-1:0] a [0:k-2];
    wire [n-1:0] t [0:k-2];
    wire [n-1:0] secand_out [0:k-2];
    wire [n-1:0] z_part [0:k-1];

    assign c[0] = {n{1'b0}};   // initial carry is 0 in all shares

    generate
        for (b = 0; b < k-1; b = b + 1) begin : gen_bit
            // a = xb[b] ^ yb[b]
            assign a[b] = xb[b] ^ yb[b];
            // t = xb[b] ^ c[b]
            assign t[b] = xb[b] ^ c[b];
            // output sum bit for this position (before final bit)
            assign z_part[b] = c[b] ^ a[b];

            // SecAnd_1 gadget (k=1)
            // Extract randomness slice for this bit
            wire [RND_PER_BIT-1:0] rnd_bit = rnd[b*RND_PER_BIT +: RND_PER_BIT];
            SecAnd_n_k #(.d(n), .k(1)) secand_inst (
                .clk(clk),
                .ina(a[b]),
                .inb(t[b]),
                .rnd(rnd_bit),
                .out(secand_out[b])
            );
            // next carry: xb[b] ^ SecAnd_out
            assign c[b+1] = xb[b] ^ secand_out[b];
        end

        // final sum bit
        assign z_part[k-1] = xb[k-1] ^ yb[k-1] ^ c[k-1];
    endgenerate

    // ------------------------------------------------------------------------
    // Pack output shares back to share‑major order
    // ------------------------------------------------------------------------
    generate
        for (b = 0; b < k; b = b + 1) begin : gen_pack
            for (s = 0; s < n; s = s + 1) begin : gen_out_share
                assign out[s*k + b] = z_part[b][s];
            end
        end
    endgenerate

endmodule
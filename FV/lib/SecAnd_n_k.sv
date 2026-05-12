// ============================================================================
// SecAnd_n_k: k-bit bitwise AND under n-share Boolean masking (HPC2 based)
// Input/Output packing: share-major order (all k bits of share 0, then share 1, ...)
// Latency: 2 cycles
// ============================================================================
module SecAnd_n_k #(
    parameter integer d = 2,           // number of shares
    parameter integer k = 1            // number of bits per value
) (
    input  wire                               clk,
    input  wire [k*d-1:0]                    ina,   // shares of a
    input  wire [k*d-1:0]                    inb,   // shares of b
    input  wire [k*d*(d-1)/2-1:0]            rnd,   // randomness (k * d*(d-1)/2 bits)
    output wire [k*d-1:0]                    out    // shares of a & b
);

    localparam HPC2_RND_BITS = d*(d-1)/2;          // randoms needed per HPC2
    localparam RND_WIDTH     = k * HPC2_RND_BITS;  // total random bits

    // Sanity check
    initial begin
        if (d < 2) $error("SecAnd_n_k: d must be at least 2 for HPC2.");
        if (HPC2_RND_BITS > 0 && $bits(rnd) != RND_WIDTH)
            $error("SecAnd_n_k: rnd width mismatch.");
    end

    // Instantiate one HPC2 gadget per bit
    genvar b, s;
    generate
        for (b = 0; b < k; b = b + 1) begin : gen_bit
            wire [d-1:0] ina_bit;   // d shares of the current bit from ina
            wire [d-1:0] inb_bit;   // d shares of the current bit from inb
            wire [d-1:0] out_bit;   // d shares of the result for this bit

            // Extract the d shares of current bit (share-major packing)
            for (s = 0; s < d; s = s + 1) begin : gen_extract
                assign ina_bit[s] = ina[s*k + b];
                assign inb_bit[s] = inb[s*k + b];
            end

            // Slice randomness for this bit
            wire [HPC2_RND_BITS-1:0] rnd_bit;
            assign rnd_bit = rnd[b*HPC2_RND_BITS +: HPC2_RND_BITS];

            // Instantiate HPC2 (single‑bit masked AND)
            MSKand_hpc2 #(.d(d)) hpc2_inst (
                .clk(clk),
                .ina(ina_bit),
                .inb(inb_bit),
                .rnd(rnd_bit),
                .out(out_bit)
            );

            // Pack output shares back into share‑major order
            for (s = 0; s < d; s = s + 1) begin : gen_pack
                assign out[s*k + b] = out_bit[s];
            end
        end
    endgenerate
endmodule